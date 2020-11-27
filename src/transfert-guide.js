//SOURCE : http://planzero.org/blog/2013/03/07/spidering_the_web_with_casperjs
// Adaptations : Arnaud d'Alayer

// Create instances
var casper = require('casper').create({
	//verbose: true,
	//logLevel: "debug",
	viewportSize: {
		width: 1440,
		height: 900
	}
});
var system = require('system');
var utils = require('utils');
var helpers = require('./helpers');

// Set the start URL
var startUrl = casper.cli.get("url");

// Authentification
var codeAcces = casper.cli.get("codeAcces");
var motDePasse = casper.cli.get("motDePasse");

// URL variables
var visitedUrls = [], pendingUrls = [];

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
var xmlOutput = casper.cli.get("xmlOutput");
var cacheOutput = casper.cli.get("cacheOutput");


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
			/*Titre du template des guides*/
			if (document.getElementsByClassName("titre").length !== 0){
				var titreH1 = document.getElementsByClassName("titre");
			}
			/*Titre du template du cahier SCI6052*/
			else {
				var titreH1 = document.getElementById("title-text");
			}
			return $('<div/>').html(titreH1).text();
		});
		
		
		var rubriques = this.evaluate(function() {
			var content = "";
			var contenu = document.getElementsByClassName("rubrique");
			
			for (var i = 0; i < contenu.length; ++i){
				content += contenu[i].outerHTML;
			}
			return content;
		});
		var basDePage = this.evaluate(function() {
			var content = "";
			var contenu = document.getElementsByClassName("bas-de-page");
			
			for (var i = 0; i < contenu.length; ++i){
				content += contenu[i].outerHTML;
			}
			return content;
		});
		
		pageXML += '\n\t<page>';
		pageXML += '\n\t\t<url>' + escapeHtml(url) + '</url>';
		pageXML += '\n\t\t<title>' + escapeHtml(pageTitle) + '</title>';
		pageXML += '\n\t\t<titre>' + escapeHtml(pageTitre) + '</titre>';
		pageXML += '\n\t\t<rubriques>';
		pageXML += '\n\t\t\t' + rubriques;
		pageXML += '\n\t\t</rubriques>';
		if (basDePage){
			
			pageXML += '\n\t\t<bas-de-page>';
			pageXML += '\n\t\t\t' + basDePage;
			pageXML += '\n\t\t</bas-de-page>';
		}
		pageXML += '\n\t</page>';
		
		
		/*Téléchargement des images (début)*/
		var images = this.evaluate(function() {
			var images = [];
			Array.prototype.forEach.call(__utils__.findAll('.confluence-embedded-image'), function(e) {
				var lien = e.getAttribute('src');
				/*console.log("lienImage : " + lien);*/
				images.push(lien);
			});
			return images;
		});
		
		var baseUrl = this.getGlobal('location').origin;
		Array.prototype.forEach.call(images, function(image) {
			var imageURL = helpers.absoluteUri(baseUrl, image);
			/*https://stackoverflow.com/questions/511761/js-function-to-get-filename-from-url*/
			var imageNom = imageURL.split('/').pop().split('#')[0].split('?')[0];
			var imageFichier = window.cacheOutput+'/images/'+imageNom;
			console.log("URL image a downloader : " + imageURL);
			console.log("Nom de l'image : " + imageNom);
			console.log("Nom du fichier : " + imageFichier);
			casper.download(imageURL, imageFichier);
			
		});
		/*Téléchargement des images (fin)*/
		
		
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
		//var baseUrl = this.getGlobal('location').origin;
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
			fs.write(xmlOutput, pageXML, 'w');
		}
	});
}

// Start spidering
/*casper.start(startUrl, function() {
	spider(startUrl);
});
*/
casper.start(startUrl, function() {
	if(casper.exists('#login-container > div > form')){
		this.echo('Authentification requise');
		
		this.fillSelectors('#login-container > div > form', {
			'input[name ="os_username"]' : codeAcces,
			'input[name ="os_password"]' : motDePasse
		}, true);
		//this.capture('./logs/login.png');
		this.thenClick('#loginButton');
	}
});
casper.then(function () {
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