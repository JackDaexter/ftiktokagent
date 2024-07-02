import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:my_app/models/domain/Account.dart';
import 'package:my_app/models/domain/SimpleProxy.dart';
import 'package:webdriver/async_io.dart';

enum BotStatus { Running, Stopped, Inactive }

enum BrowserStatus {
  Active,
  Inactive,
  Shadowbanned,
  Suspended,
  Testing,
  Captcha,
  Code,
  Running
}

const List<String> tikTokTrends = <String>[
  "Grocery List Duel",
  "String Magic Show",
  "Word Chain Addict",
  "Never List Challenge",
  "String Clue Hunt",
  "Empty Fridge Blues",
  "First Last Word Show",
  "Double Trouble List",
  "ABC Sort Race",
  "String Quiz Test",
  "Scrambled Fix",
  "Would You String?",
  "Rhyme Time List",
  "Mad Libs Twist",
  "Blindfold Word Hunt",
  "String Sort Race",
  "Story Time List",
  "Dance String List",
  "Don't Say String",
  "Reverse Charades",
  "Creative Skit",
  "Rap List Methods",
  "Comment Quiz List",
  "Duet Your Twist",
  "Best Trend Compil"
];

class Streamer {
  Account accountData;
  SimpleProxy? proxieData;
  late WebDriver driver;
  var numberOfStream = 0;
  var browserStatus = BrowserStatus.Inactive;
  var accountIsSubscribed = Status.unsubscribe;
  var wasBlocked = false;

  Streamer({required this.accountData, proxieData, driver})
      : this.proxieData = proxieData;

  Future<void> browserSetup() async {
    driver = await createDriver(
        uri: Uri.parse('http://localhost:4444/wd/hub/'),
        desired: {
          'browserName': 'chrome',
          'goog:chromeOptions': {
            'args': [
              '--disable-gpu',
              '--no-sandbox',
              '--disable-dev-shm-usage',
              '--disable-extensions',
              '--disable-popup-blocking',
              '--mute-audio'
            ]
          }
        });
  }

  Future<void> Start() async {
    Process chromeDriverProcess = await Process.start(
        'C:\\Users\\franc\\IdeaProjects\\ftiktokagent\\lib\\core\\chromedriver.exe',
        ['--port=4444', '--url-base=wd/hub']);
    bool wasBlocked = false;

    try {
      await browserSetup();
      browserStatus = BrowserStatus.Running;

      var duration = const Duration(seconds: 20);
      await driver.timeouts.setImplicitTimeout(const Duration(seconds: 20));
      await driver.get('https://www.tiktok.com');

      // Take a simple screenshot
      var url = driver.currentUrl.toString();
      if (url.contains("redirect_url")) {
        log("Redirecting to login page");
        await loginForRedirect(wasBlocked);
      } else {
        log("Else of redirection to login page");
        //await driver.keyboard.sendKeys(Keyboard.escape);
        var element = await driver
            .findElement(By.xpath("//*[@id=\"header-login-button\"]"));
        await element.click();

        var loginButtonInContainer = await driver.findElement(
            By.xpath("//*[@id=\"loginContainer\"]/div/div/div/div[2]"));
        await loginButtonInContainer.click();
      }

      if (await ConnexionPageIsPresent(driver)) {
        log("Ferme ta gueule");

        FillConnexionField(driver);
      } else {
        log("My little dog");

        await driver
            .findElement(
                By.xpath("//*[@id=\"loginContainer\"]/div/form/div[1]/a"))
            .then((elem) async => await elem.click());

        if (await WeAreOnPhoneAccountCreation(driver)) {
          await driver
              .findElement(
                  By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[1]/a"))
              .then((elem) async => await elem.click());
        }
        FillConnexionField(driver);
      }
      StreamWhileNonStop();
    } catch (e) {
      log(e.toString());
      chromeDriverProcess.kill();
    }
  }

  void StreamWhileNonStop() {
    math.Random randomNumber = new math.Random();

    while (true) {
      int trendToSearch = randomNumber.nextInt(0) + tikTokTrends.length - 1;
      int videoToSelect = randomNumber.nextInt(6);
      int waitBetweenNextVideo = randomNumber.nextInt(25);
      int numberVideoAfterNextSearch = randomNumber.nextInt(22) + 3;

      driver
          .findElement(
              By.xpath("//*[@id=\"app-header\"]/div/div[2]/div/form/input"))
          .then((elem) => elem.sendKeys(tikTokTrends[trendToSearch]));
      driver
          .findElement(
              By.xpath("//*[@id=\"app-header\"]/div/div[2]/div/form/button"))
          .then((elem) => elem.click()); // click on search

      sleep(Duration(milliseconds: 5000));

      driver
          .findElement(By.xpath(
              "//*[@id=\"tabs-0-panel-search_top\"]/div/div/div[{$videoToSelect}]/div[1]"))
          .then((elem) => elem.click());
      StreamVideo();
    }
  }

  void StreamVideo() {
    math.Random randomNumber = new math.Random();
    //*[@id="main-content-video_detail"]/div/div[2]/div/div[1]/div[1]/div[3]/div[1]/button[2]
    int waitBetweenNextVideo = randomNumber.nextInt(45) + 15;
    int numberVideoAfterNextSearch = randomNumber.nextInt(20) + 3;
    int waitTime = randomNumber.nextInt(4) + 1;
    for (int i = 0; i < numberVideoAfterNextSearch; i++) {
      sleep(Duration(milliseconds: 1500));

      sleep(Duration(seconds: waitBetweenNextVideo));
      driver
          .findElement(By.xpath(
              "//*[@id=\"tabs-0-panel-search_top\"]/div[3]/div/div[1]/button[3]"))
          .then((e) => e.click()); // next video

      if (i % numberVideoAfterNextSearch == 0) {
        sleep(Duration(minutes: waitTime));
      }
      numberOfStream += 1;
    }
    driver
        .findElement(By.xpath(
            "//*[@id=\"tabs-0-panel-search_top\"]/div[3]/div/div[1]/button[1]"))
        .then((e) => e.click());
  }

  Future<void> loginForRedirect(bool wasBlocked) async {
    driver
        .findElement(const By.xpath(
            '//*[@id=\"loginContainer\"]/div/div/div/div[3]/div[2]'))
        .then((element) => element.click());
    driver
        .findElement(
            const By.xpath('//*[@id=\"loginContainer\"]/div[1]/form/div[1]/a'))
        .then((element) => element.click());

    driver
        .findElement(const By.xpath(
            '//*[@id=\"loginContainer\"]/div[1]/form/div[1]/input'))
        .then((element) => element.sendKeys(accountData.email));

    driver
        .findElement(const By.xpath(
            '//*[@id=\"loginContainer\"]/div[1]/form/div[2]/div/input'))
        .then((element) => element.sendKeys(accountData.password));
    driver
        .findElement(By.xpath("//*[@id=\"loginContainer\"]/div[1]/form/button"))
        .then(
            (elem) => elem.click()); // Button to switch from email to telephone
    WaitWhileCaptchaPresent(wasBlocked);
    WaitWhileCodeVerificationIsPresent(wasBlocked);
    sleep(Duration(milliseconds: 1500));
    driver.get("https://www.tiktok.com/search");
  }

  Future<void> FillConnexionField(WebDriver driver) async {
    var wasBlocked = false;
    var loginInput = await driver.findElement(
        By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[1]/input"));
    await loginInput.sendKeys(accountData.email);

    var passwordInput = await driver.findElement(
        By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[2]/div/input"));
    await passwordInput.sendKeys(accountData.password);

    var loginButton = await driver.findElement(
        By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/button"));
    await loginButton.click();

    await WaitWhileCaptchaPresent(wasBlocked);
    await WaitWhileCodeVerificationIsPresent(wasBlocked);
  }

  Future<void> WaitWhileCaptchaPresent(bool wasBlocked) async {
    while (await CaptchaIsAsked(driver)) {
      log("Sleep bro");
      browserStatus = browserStatus == BrowserStatus.Captcha
          ? browserStatus
          : BrowserStatus.Captcha;
      sleep(Duration(milliseconds: 1500));
      wasBlocked = true;
    }
    browserStatus = BrowserStatus.Running;
  }

  Future<void> WaitWhileCodeVerificationIsPresent(bool wasBlocked) async {
    while (await VerificationCodeIsAsked(driver)) {
      browserStatus = browserStatus == BrowserStatus.Captcha
          ? browserStatus
          : BrowserStatus.Code;
      sleep(Duration(milliseconds: 1500));
      wasBlocked = true;
    }
    browserStatus = BrowserStatus.Running;
  }

  static Future<bool> CaptchaIsAsked(WebDriver driver) async {
    try {
      await driver.findElement(By.xpath("//*[@id=\"captcha_container\"]/div"));
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> ConnexionPageIsPresent(WebDriver driver) async {
    try {
      var isPresent = await driver
          .findElement(By.xpath("//*[@id=\"loginContainer\"]/div[2]/div"));
      log(isPresent.toString());
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> WeAreOnPhoneAccountCreation(WebDriver driver) async {
    try {
      await driver.findElement(
          By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[1]/a"));
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> VerificationCodeIsAsked(WebDriver driver) async {
    try {
      await driver.findElement(By.xpath("/html/body/div[9]/div[2]"));
      return true;
    } catch (Exception) {
      return false;
    }
  }

  static Future<bool> SubscribeLinkIsPresent(WebDriver driver) async {
    try {
      await driver
          .findElement(By.xpath("//*[@id=\"login-modal\"]/div[1]/div[3]/a"));
      return true;
    } catch (Exception) {
      return false;
    }
  }

  @override
  String toString() {
    return 'Streamer{accountData: $accountData, proxieData: $proxieData, numberOfStream: $numberOfStream, browserStatus: $browserStatus, accountIsSubscribed: $accountIsSubscribed, wasBlocked: $wasBlocked}';
  }
}
