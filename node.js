// nvm use v0.10.35 ; node node.js
var wd = require('wd')
//var wd = require('/home/hernan/p/wd/')
var browser = wd.remote("127.0.0.1", 5555, "teste", "teste123")
//var browser = wd.remote("127.0.0.1", 8001, "teste", "teste123")

var assert = require('assert');
browser.on('status', function(info){
  console.log('\x1b[36m%s\x1b[0m', info);
});
 
browser.on('command', function(meth, path){
  console.log(' > \x1b[33m%s\x1b[0m: %s', meth, path);
});
 
browser.init({
//  browserName:'firefox'
      tags : ["examples"]
    , name: "This is an example test"
//  , browserName: 'ie'
//  , browserName: 'firefox'
//  , browserName: 'firefox'
//  , version: 33
//  , platform: 'linux'


    , browserName: 'ie'
    , version: 10
    , platform: 'windows7'

}, function() {
 
    browser.get("http://saucelabs.com/test/guinea-pig", function() {
    browser.title(function(err, title) {
        assert.ok(~title.indexOf('I am a page title - Sauce Labs'), 'Wrong title!');
        browser.elementById('comments', function(err, el) {
        el.sendKeys("this is not a comment", function(err) {
            browser.elementById('submit', function(err, el) {
            el.click(function() {
                browser.eval("window.location.href", function(err, title) {
//              assert.ok(~title.indexOf('#'), 'Wrong title!');
                browser.elementById("your_comments", function(err, el) {
                    el.textPresent("this is not a comment", function(err, present) {
                    assert.ok(present, "Comments not correct");
                    el.text(function(err, text) {
                        console.log(text);
                        browser.quit();
                    })
                    })
                })
                })
            })
            })
        })
        })
    })
    })
});
