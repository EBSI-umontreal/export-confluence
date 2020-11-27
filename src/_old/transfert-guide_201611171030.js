//SOURCE : http://planzero.org/blog/2013/03/07/spidering_the_web_with_casperjs
// Adaptations : Arnaud d'Alayer

// Set the start URL
var startUrl = 'https://wiki.umontreal.ca/pages/viewpage.action?pageId=124093923';
//var startUrl = 'https://wiki.umontreal.ca/pages/viewpage.action?pageId=124097391';

// URL variables
var visitedUrls = [], pendingUrls = [];

// Create instances
var casper = require('casper').create({
	viewportSize: {
		width: 1440,
		height: 900
	}
});
var utils = require('utils');
var helpers = require('./helpers');



//captures d'ecran
var compteurCaptureEcran = 0;
function capturer(e) {
	e.echo('  -> capture' + compteurCaptureEcran + '.png', "html");
	e.captureSelector('./logs/capture' + compteurCaptureEcran++ + '.png', "html");
	e.echo('');
}

//XML Output
var pageXML = "";
pageXML = '<?xml version="1.0" encoding="UTF-8"?>';
pageXML += '\n<!DOCTYPE guide [';
pageXML += '\n\t<!ENTITY nbsp "&#160;">';
pageXML += '\n]>';
pageXML += '\n<guide>';


var fs = require('fs');
var filename = 'out/content.xml';

//
function escapeHtml(unsafe) {
	return unsafe
		.replace(/&/g, "&amp;")
		.replace(/</g, "&lt;")
		.replace(/>/g, "&gt;")
		.replace(/"/g, "&quot;")
		.replace(/'/g, "&#039;");
 }


// Spider from the given URL
function spider(url) {

	// Add the URL to the visited stack
	visitedUrls.push(url);

	// Open the URL
	casper.open(url).then(function() {

		// Set the status style based on server status code
		var status = this.status().currentHTTPStatus;
		switch(status) {
			case 200: var statusStyle = { fg: 'green', bold: true }; break;
			case 404: var statusStyle = { fg: 'red', bold: true }; break;
			 default: var statusStyle = { fg: 'magenta', bold: true }; break;
		}

		// Display the spidered URL and status
		this.echo(this.colorizer.format(status, statusStyle) + ' ' + url);
		
		//ARNAUD : Produire noeud XML des infos de la page
		//capturer(this);
		var pageTitle = this.fetchText('title');
		var pageTitre = this.evaluate(function() {
			var titreH1 = document.getElementsByClassName("titre");
			return $('<div/>').html(titreH1).text();
		});
		
		
		var pageContenu = this.evaluate(function() {
			var rubriques = "";
			var contenu = document.getElementsByClassName("rubrique");
			
			for (var i = 0; i < contenu.length; ++i){
				rubriques += contenu[i].innerHTML;
			}
			return rubriques;
			//console.log(contenu[0].innerHTML);
			//return contenu[0].innerHTML;
			//return $('<div/>').html(contenu).text();
		});
		pageXML += '\n\t<page>';
		pageXML += '\n\t\t<url>' + escapeHtml(url) + '</url>';
		pageXML += '\n\t\t<title>' + escapeHtml(pageTitle) + '</title>';
		pageXML += '\n\t\t<title>' + escapeHtml(pageTitre) + '</title>';
		pageXML += '\n\t\t<contenu>';
		pageXML += '\n\t\t\t' + pageContenu;
		pageXML += '\n\t\t</contenu>';
		pageXML += '\n\t</page>';


		// Find links present on this page
		//ARNAUD : Se limiter à la TdM des guides
		var links = this.evaluate(function() {
			var links = [];
			Array.prototype.forEach.call(__utils__.findAll('.table-des-matières a[href]'), function(e) {
				var lien = e.getAttribute('href');
				//console.log("lien : " + lien);
				if (lien.indexOf('#') > -1){
					lien = lien.substr(0, lien.indexOf('#'));
					//console.log("lienRetouche : " + lien);
				}
				links.push(lien);
			});
			return links;
		});

		// Add newly found URLs to the stack
		var baseUrl = this.getGlobal('location').origin;
		Array.prototype.forEach.call(links, function(link) {
			var newUrl = helpers.absoluteUri(baseUrl, link);
			if (pendingUrls.indexOf(newUrl) == -1 && visitedUrls.indexOf(newUrl) == -1) {
				//casper.echo(casper.colorizer.format('-> Pushed ' + newUrl + ' onto the stack', { fg: 'magenta' }));
				pendingUrls.push(newUrl);
			}
		});

		// If there are URLs to be processed
		if (pendingUrls.length > 0) {
			var nextUrl = pendingUrls.shift();
			//this.echo(this.colorizer.format('<- Popped ' + nextUrl + ' from the stack', { fg: 'blue' }));
			spider(nextUrl);
		}
		else {
			pageXML += '\n</guide>';
			fs.write(filename, pageXML, 'w');
		}
	});
}

// Start spidering
casper.start(startUrl, function() {
	spider(startUrl);
});

// Start the run
casper.run();


/* Avoir plus de détails en cas d'erreur
Source : http://stackoverflow.com/questions/11864373/console-log-doesnt-work-in-casperjs-evaluate-with-settimout */
var utils = require('utils');
casper.on('page.error', function exitWithError(msg, stack) {
	stack = stack.reduce(function (accum, frame) {
		return accum + utils.format('\tat %s (%s:%d)\n',
			frame.function || '<anonymous>',
			frame.file,
			frame.line
		);
	}, '');
	this.die(['Client-side error', msg, stack].join('\n'), 1);
});

/* Voir le résultat de console.log
Source : http://stackoverflow.com/questions/10745345/output-client-side-console-with-casper-phantomjs */
casper.on('remote.message', function(message) {
	this.echo(message);
});