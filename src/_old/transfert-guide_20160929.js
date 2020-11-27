/*SOURCE : https://gist.github.com/imjared/5201405 */

/*jshint strict:false*/
/*global CasperError console phantom require*/

/**
 * grab links and push them into xml
 */
var casper = require("casper").create({
	logLevel: "debug"
});

var numberOfLinks = 0;
var currentLink = 0;
var links = [];
var buildPage, capture, selectLink, grabContent, writeContent;
var pageXML = '<channel>';
var fs = require('fs');
var filename = 'out/content.xml'

casper.start("https://wiki.umontreal.ca/pages/viewpage.action?pageId=124093923", function() {
	numberOfLinks = this.evaluate(function() {
		return __utils__.findAll('.table-des-matières a[href]').length;
	});
	this.echo(numberOfLinks + " items found");
	
	// cause jquery makes it easier
	//casper.page.injectJs('/PATH/TO/jquery.js');
});

// Capture links
capture = function() {
	links = this.evaluate(function() {
		var link = [];
		jQuery('.table-des-matières a[href]').each(function() {
			link.push($(this).attr('href'));
		});
		return link;
	});
	//utils.dump(links);
	this.then(selectLink);
};

selectLink = function() {
	if (currentLink < numberOfLinks) {
		this.then(grabContent);
	} else {
		pageXML += '</channel>'
	}
};

grabContent = function() {
	var pageTitle; 
	var pageTitre;
	var pageContenu;
	var pageBasDePage;
	
	casper.open(links[currentLink]).then(function() {
		
		// these will eventually be mapped into XML nodes
		pageTitle = this.fetchText('title');
		pageTitre = this.evaluate(function() {
			var contenu = document.getElementsByClassName("guide-ebsi");
			//console.log(contenu[0].innerHTML);
			return contenu[0].innerHTML;
		});
		/*pageContenu = this.evaluate(function() {
			var contenu = document.getElementsByClassName("rubrique");
			console.log(contenu[0].innerHTML);
			return contenu[0].innerHTML;
		});
		
		pageBasDePage = this.evaluate(function() {
			var contenu = document.getElementsByClassName("bas-de-page");
			return contenu[0].innerHTML;
		});
		*/
		
		this.echo( 'processing item ' + currentLink + ' out of ' + numberOfLinks + ' | ');
		pageXML += '\n<page>';
		pageXML += '\n\t<url><![CDATA[' + links[currentLink] + ']]></url>';
		pageXML += '\n\t<title><![CDATA[' + pageTitle + ']]></title>';
		pageXML += '\n\t<titre><![CDATA[' + pageTitre + ']]></titre>';
		/*pageXML += '\n\t<contenu><![CDATA[' + pageContenu + ']]></contenu>';
		pageXML += '\n\t<bas-de-page><![CDATA[' + pageBasDePage + ']]></bas-de-page>';
		*/
		pageXML += '\n</page>';
	});

	this.then(buildPage);
};

buildPage = function() {
	this.echo('writing to ' + filename);
	fs.write(filename, pageXML, 'w');

	currentLink++;
	this.then(selectLink);
};

casper.then(capture);
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