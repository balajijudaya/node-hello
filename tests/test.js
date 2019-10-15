var http = require('http');
var app = require('../app');
var expect  = require('chai').expect;
var request = require('request');

var server;

before(() => {
	server = http.createServer(app).listen(8000);
});

it('Main page content', function(done) {
    request('http://localhost:8000' , function(error, response, body) {
        expect(body).to.equal('Hello World\n');
        done();
    });
});

after(function(done) {
	server.close();
    console.log("stopped");
    done();
});
    