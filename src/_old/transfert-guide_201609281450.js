var urlGuide = 'https://wiki.umontreal.ca/pages/viewpage.action?pageId=124093923';

var wait = 2000;
var compteurCaptureEcran = 0;
var chaineIdent = "Guide";

var casper = require('casper').create({
	verbose: false,
	logLevel: 'debug',
	viewportSize: {
		width: 1440,
		height: 900
	}
});


/* capturer() : faire une capture d'écran et afficher un message avec l'identifiant de la capture */
function capturer(e) {
	e.echo('  -> ' + chaineIdent + compteurCaptureEcran + '.png', "html");
	e.captureSelector('./logs/' + chaineIdent + compteurCaptureEcran++ + '.png', "html");
	e.echo('');
}


/* ==============================
   Authentification
   ==============================
*/

/* ÉTAPE 1 : CONNEXION AU WIKI */
casper.start(urlGuide, function() {
	casper.waitForUrl(urlGuide, function() {
		capturer(this);
	});
});

/* ÉTAPE 2 : RÉCUPÉRER LES PAGES ASSOCIÉES */
/* SOURCE : http://stackoverflow.com/questions/20224687/how-to-follow-all-links-in-casperjs */
casper.then(function getLinks(){
     links = this.evaluate(function(){
        var links = document.getElementsByTagName('a');
        links = Array.prototype.map.call(links,function(link){
            return link.getAttribute('href');
        });
        return links;
    });
});
casper.then(function(){
    this.each(links,function(self,link){
        self.thenOpen(link,function(a){
            this.echo(this.getCurrentUrl());
        });
    });
});




casper.run();