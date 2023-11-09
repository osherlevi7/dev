import pytest
from selenium import webdriver
@pytest.fixture
def browser():
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    driver = webdriver.Remote(
        command_executor='http://localhost:4444/wd/hub',
        desired_capabilities=options.to_capabilities()
    )
    yield driver
    driver.quit()
def test_google_search(browser):
    browser.get('https://www.google.com')
    assert 'Google' in browser.title
