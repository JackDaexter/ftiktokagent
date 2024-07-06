import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:my_app/models/domain/Account.dart';
import 'package:my_app/models/domain/SimpleProxy.dart';
import 'package:webdriver/async_io.dart';

import '../api/get_email_gmail.dart';

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
  Account account;
  SimpleProxy? proxieData;
  late WebDriver driver;
  var numberOfStream = 0;
  var browserStatus = BrowserStatus.Inactive;
  var wasBlocked = false;

  Streamer({required this.account, proxieData, driver})
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
              '--disable-extensions',
              '--disable-popup-blocking',
              '--mute-audio'
            ]
          }
        });
  }

  void start(SendPort sendport) async {
    Process chromeDriverProcess = await Process.start(
        'C:\\Users\\franc\\IdeaProjects\\ftiktokagent\\lib\\core\\chromedriver.exe',
        ['--port=4444', '--url-base=wd/hub']);
    bool wasBlocked = false;

    try {
      await browserSetup();
      browserStatus = BrowserStatus.Running;

      await driver.timeouts.setImplicitTimeout(const Duration(seconds: 10));
      await driver.get('https://www.tiktok.com');

      var url = driver.currentUrl.toString();
      await subscribeIfAccountNotSubscribe();
      await goToLoginPage(url, wasBlocked);
      await connectAccountToTiktok();
      streamWhileNonStop();
    } catch (e) {
      chromeDriverProcess.kill();
    }
  }

  Future<void> goToLoginPage(String url, bool wasBlocked) async {
    if (url.contains("redirect_url")) {
      await loginForRedirect(wasBlocked);
    } else {
      var element = await driver
          .findElement(const By.xpath("//*[@id=\"header-login-button\"]"));
      await element.click();

      var loginButtonInContainer = await driver.findElement(
          By.xpath("//*[@id=\"loginContainer\"]/div/div/div/div[2]"));
      await loginButtonInContainer.click();
    }
  }

  Future<void> connectAccountToTiktok() async {
    if (await ConnexionPageIsPresent(driver)) {
      log("Ferme ta gueule");

      await fillConnexionField();
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
      log("Passe mec");
      await fillConnexionField();
    }
  }

  Future<void> streamWhileNonStop() async {
    math.Random randomNumber = new math.Random();

    while (true) {
      int trendToSearch = randomNumber.nextInt(1) + tikTokTrends.length - 1;
      int videoToSelect = randomNumber.nextInt(6);
      int waitBetweenNextVideo = randomNumber.nextInt(25);
      int numberVideoAfterNextSearch = randomNumber.nextInt(22) + 3;

      await driver
          .findElement(
              By.xpath("//*[@id=\"app-header\"]/div/div[2]/div/form/input"))
          .then((elem) => elem.sendKeys(tikTokTrends[trendToSearch]));
      await driver
          .findElement(
              By.xpath("//*[@id=\"app-header\"]/div/div[2]/div/form/button"))
          .then((elem) => elem.click()); // click on search

      sleep(Duration(milliseconds: 5000));

      await driver
          .findElement(By.xpath(
              "//*[@id=\"tabs-0-panel-search_top\"]/div/div/div[${videoToSelect}]/div[1]"))
          .then((elem) => elem.click());
      streamVideo();
    }
  }

  Future<void> streamVideo() async {
    math.Random randomNumber = new math.Random();
    //*[@id="main-content-video_detail"]/div/div[2]/div/div[1]/div[1]/div[3]/div[1]/button[2]
    int waitBetweenNextVideo = randomNumber.nextInt(45) + 15;
    int numberVideoAfterNextSearch = randomNumber.nextInt(20) + 3;
    int waitTime = randomNumber.nextInt(4) + 1;
    for (int i = 0; i < numberVideoAfterNextSearch; i++) {
      sleep(Duration(seconds: waitBetweenNextVideo));
      await driver
          .findElement(By.xpath(
              "//*[@id=\"tabs-0-panel-search_top\"]/div[3]/div/div[1]/button[3]"))
          .then((e) => e.click()); // next video

      if (i % numberVideoAfterNextSearch == 0) {
        sleep(Duration(minutes: waitTime));
      }
      numberOfStream += 1;
    }
    await driver
        .findElement(By.xpath(
            "//*[@id=\"tabs-0-panel-search_top\"]/div[3]/div/div[1]/button[1]"))
        .then((e) => e.click());
  }

  Future<void> subscribeIfAccountNotSubscribe() async {
    if (account.status == Status.unsubscribe) {
      await driver
          .findElement(By.xpath("//*[@id=\"login-modal\"]/div[1]/div[2]/a"))
          .then((link) => link.click());
      await driver
          .findElement(By.xpath(
              "//*[@id=\"loginContainer\"]/div[2]/div/div/div[2]/div[1]/div[2]"))
          .then((link) => link.click());

      await FillBirthDate(driver);
      await SelectSubscriptionByEmail();

      await driver
          .findElement(By.xpath(
              "//*[@id=\"loginContainer\"]/div[2]/form/div[5]/div/input"))
          .then((element) => element.sendKeys(account.email));
      await driver
          .findElement(By.xpath(
              "//*[@id=\"loginContainer\"]/div[2]/form/div[6]/div/input"))
          .then((element) => element.sendKeys(account.password));
      await driver
          .findElement(By.xpath(
              "//*[@id=\"loginContainer\"]/div[2]/form/div[7]/div/button"))
          .then((element) => element.click());

      await recupererLeCodeRecuParMail();
      //Year

      await driver
          .findElement(By.xpath(
              "//*[@id=\"main-content-video_detail\"]/div/div[2]/div/div[1]/div[1]/div[3]/div[1]/button[2]"))
          .then((e) => e.click());
      account.status = Status.subscribe;
    }
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
        .then((element) => element.sendKeys(account.email));

    driver
        .findElement(const By.xpath(
            '//*[@id=\"loginContainer\"]/div[1]/form/div[2]/div/input'))
        .then((element) => element.sendKeys(account.password));
    driver
        .findElement(By.xpath("//*[@id=\"loginContainer\"]/div[1]/form/button"))
        .then(
            (elem) => elem.click()); // Button to switch from email to telephone
    waitWhileCaptchaPresent(wasBlocked);
    waitWhileCodeVerificationIsPresent(wasBlocked);
    sleep(Duration(milliseconds: 1500));
    driver.get("https://www.tiktok.com/search");
  }

  Future<void> fillConnexionField() async {
    try {
      sleep(Duration(milliseconds: 2500));

      var loginInput = await driver.findElement(
          By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[1]/input"));

      await loginInput.sendKeys(account.email);

      var passwordInput = await driver.findElement(
          By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[2]/div/input"));
      await passwordInput.sendKeys(account.password);
      log("Passwordmec");

      var loginButton = await driver.findElement(
          By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/button"));
      await loginButton.click();
      log("LoginButtin");

      await waitWhileCaptchaPresent(wasBlocked);
      await waitWhileCodeVerificationIsPresent(wasBlocked);
    } catch (Exception) {
      log("Erreur mec");
      log(Exception.toString());
      sleep(Duration(hours: 1));
    }
  }

  Future<void> waitWhileCaptchaPresent(bool wasBlocked) async {
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

  Future<void> waitWhileCodeVerificationIsPresent(bool wasBlocked) async {
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

  Future<void> FillBirthDate(WebDriver _webDriver) async {
    var monthOfBirth = math.Random().nextInt(11) + 1;
    var dayOfBirth = math.Random().nextInt(29) + 1;
    var yearOfBirth = math.Random().nextInt(45) + 20;

    await _webDriver
        .findElement(
            By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[2]/div[1]"))
        .then((elem) => elem.click()); //Month
    _webDriver
        .findElement(
            By.xpath("//*[@id=\"Month-options-item-${monthOfBirth}\"]"))
        .then((elem) => elem.click()); //Month

    sleep(Duration(milliseconds: 1500));
    _webDriver
        .findElement(
            By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[2]/div[2]"))
        .then((elem) => elem.click()); //Day
    _webDriver
        .findElement(By.xpath("//*[@id=\"Day-options-item-${dayOfBirth}\"]"))
        .then((elem) => elem.click()); //Day

    _webDriver
        .findElement(
            By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[2]/div[3]"))
        .then((elem) => elem.click()); //Year
    _webDriver
        .findElement(By.xpath("//*[@id=\"Year-options-item-${yearOfBirth}\"]"))
        .then((elem) => elem.click()); //Year
  }

  Future<void> SelectSubscriptionByEmail() async {
    try {
      await driver
          .findElement(
              By.xpath("//*[@id=\"loginContainer\"]/div/form/div[4]/a"))
          .then((elem) => elem.click());
      return;
    } catch (Exception) {
      return;
    }
  }

  @override
  String toString() {
    return 'Streamer{accountData: $account, proxieData: $proxieData, numberOfStream: $numberOfStream, browserStatus: $browserStatus, accountIsSubscribed: ${account.status}, wasBlocked: $wasBlocked}';
  }

  Future<String> recupererLeCodeRecuParMail() async {
    var code = await fetchInbox(account.email);
    log(code.toString());
    return code.body;
  }
}
