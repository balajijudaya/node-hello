const { Given, When, Then } = require('cucumber');
const {Builder} = require('selenium-webdriver');
const {assert} = require('chai');
var chrome = require('selenium-webdriver/chrome')

let driver = new Builder().forBrowser('chrome')
                            .setChromeOptions(new chrome.Options().headless())
                            .build();

Given('I am a node-hello app user', async function () {
});

When('I visit the home page',async function () {
    await driver.get(process.env.TARGET_URL);
});

Then('I should be greeted with message "Hello World"', async function () {
    let actualResult = await driver.getPageSource();
    assert.include(actualResult, 'Hello World');
});