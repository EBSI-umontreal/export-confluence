// Create instances
var system = require('system');
var casper = require('casper').create({
	verbose: true,
    logLevel: "debug",
	viewportSize: {
		width: 1440,
		height: 900
	}
});


// Start spidering
/*
casper.start("https://wiki.umontreal.ca/login.action", function() {
	this.fillSelectors('#login-container > div > form', {
			'input[name ="os_username"]' : 'username',
			'input[name ="os_password"]' : 'password'
		}, true);
	this.capture('./logs/login.png');
	this.thenClick('#loginButton');
});
casper.then(function () {
	this.capture('./logs/logedin.png');
});	
*/

casper.start("https://wiki.umontreal.ca/display/~dufourch/SCI6052+Cahier+des+protocoles", function() {
	if(casper.exists('#login-container > div > form')){
	   this.echo('Authentification requise');
	   
	   this.echo('Entrez votre code d acces :');
	   var codeAcces = system.stdin.readLine();
	   this.echo('Entrez votre UNIP ');
	   var motDePasse = system.stdin.readLine();
	   
	   /*
	   var codeAcces = this.ask('Code d\'accès : ');
	   var motDePasse = this.ask('Mot de passe (UNIP) : ');
	   */
	   
	   this.fillSelectors('#login-container > div > form', {
			'input[name ="os_username"]' : codeAcces,
			'input[name ="os_password"]' : motDePasse
		}, true);
		this.capture('./logs/login.png');
		this.thenClick('#loginButton');
	   
	}
	
	
});
casper.then(function () {
	this.capture('./logs/logedin.png');
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

function capturer(e) {
	e.echo('  -> capture login.png', "html");
	e.captureSelector('./logs/login.png', "html");
	e.echo('');
}