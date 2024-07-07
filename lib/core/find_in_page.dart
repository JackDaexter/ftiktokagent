import 'dart:developer';

import 'package:webdriver/async_core.dart';

class FindInPage {
//*[@id="tiktok-verify-ele"]
  //*[@id="tiktok-verify-ele"]
  //*[@id="tiktok-verify-ele"]/div
  static Future<bool> captchaIsAskedWhileConnecting(WebDriver driver) async {
    try {
      await driver
          .findElement(const By.xpath("//*[@id=\"captcha_container\"]/div"));
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> captchaIsAskedWhileStreaming(WebDriver driver) async {
    try {
      await driver
          .findElement(const By.xpath("//*[@id=\"tiktok-verify-ele\"]/div"));
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> connexionPageIsPresent(WebDriver driver) async {
    try {
      var isPresent = await driver
          .findElement(By.xpath("//*[@id=\"loginContainer\"]/div[2]/div"));
      log(isPresent.toString());
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> weAreOnPhoneAccountCreation(WebDriver driver) async {
    try {
      await driver.findElement(
          By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[1]/a"));
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> verificationCodeIsAsked(WebDriver driver) async {
    try {
      await driver.findElement(By.xpath("/html/body/div[9]/div[2]"));
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> subscribeLinkIsPresent(WebDriver driver) async {
    try {
      await driver
          .findElement(By.xpath("//*[@id=\"login-modal\"]/div[1]/div[3]/a"));
      return true;
    } catch (Exception) {
      return false;
    }
  }
}
