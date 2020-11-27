// Set the start URL
var startUrl = 'https://wiki.umontreal.ca/pages/viewpage.action?pageId=124093923';

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
var pageXML = '<guide>';
var fs = require('fs');
var filename = 'out/content.xml';


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
		
		//MON TRAITEMENT ICI
		capturer(this);
		var pageTitle = pageTitle = this.fetchText('title');
		var pageContenu = this.evaluate(function() {
			var contenu = document.getElementsByClassName("guide-ebsi");
			//console.log(contenu[0].innerHTML);
			return contenu[0].innerHTML;
		});
		pageXML += '\n\t<page>';
		pageXML += '\n\t\t<url><![CDATA[' + url + ']]></url>';
		pageXML += '\n\t\t<title><![CDATA[' + pageTitle + ']]></title>';
		pageXML += '\n\t\t<contenu><![CDATA[' + pageContenu + ']]></contenu>';
		pageXML += '\n\t</page>';


		// Find links present on this page
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