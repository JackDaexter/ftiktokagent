import 'package:webdriver/async_core.dart';

class SelectInPage {
  static Future<void> selectAVideo(WebDriver driver, int videoToSelect) async {
    await driver
        .findElement(By.xpath(
            "//*[@id=\"tabs-0-panel-search_top\"]/div/div/div[$videoToSelect]/div[1]"))
        .then((elem) => elem.click());
  }

  static Future<void> refusedCookieAsked(WebDriver driver) async {
    await driver
        .findElement(
            By.xpath("/html/body/tiktok-cookie-banner//div/div[2]/button[1]"))
        .then((elem) => elem.click());
  }

  static Future<void> selectSubscriptionByEmail(WebDriver driver) async {
    try {
      await driver
          .findElement(
              const By.xpath("//*[@id=\"loginContainer\"]/div/form/div[4]/a"))
          .then((elem) => elem.click());
      return;
    } on Exception {
      throw Exception("selectSubscriptionByEmail failed");
    }
  }
}
