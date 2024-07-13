import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:my_app/core/find_in_page.dart';
import 'package:my_app/core/select_in_page.dart';
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
  SendPort? sendPort;

  Streamer({required this.account, proxieData, driver})
      : this.proxieData = proxieData;

  Streamer.streamed(
      {required this.account,
      this.proxieData,
      required this.numberOfStream,
      required this.browserStatus,
      wasBlocked,
      driver});

  Future<void> browserSetup(SimpleProxy? proxieData) async {
    if (proxieData == null) {
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
      await driver.timeouts.setImplicitTimeout(const Duration(seconds: 10));
      return;
    } else {
      driver = await createDriver(
          uri: Uri.parse('http://localhost:4444/wd/hub/'),
          desired: {
            'browserName': 'chrome',
            'proxy': {
              'proxyType': 'manual',
              'httpProxy': "${proxieData.ip}:${proxieData.port}",
              'sslProxy': "${proxieData.ip}:${proxieData.port}",
            },
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

    await driver.timeouts.setImplicitTimeout(const Duration(seconds: 10));
  }

  static Streamer clone(Account account, SimpleProxy? simpleProxy,
      int numberOfStream, BrowserStatus browserStatus) {
    return new Streamer.streamed(
        account: account,
        proxieData: simpleProxy,
        numberOfStream: numberOfStream,
        browserStatus: browserStatus);
  }

  void start(List<dynamic> arguments) async {
    var currentPath = Directory.current.path;
    Process chromeDriverProcess = await Process.start(
        '$currentPath\\chromedriver.exe', ['--port=4444', '--url-base=wd/hub']);
    bool wasBlocked = false;
    sendPort = arguments[0] as SendPort;

    try {
      SimpleProxy? proxieData = arguments[1] as SimpleProxy?;
      await browserSetup(proxieData);
      browserStatus = BrowserStatus.Running;
      var clone =
          Streamer.clone(account, proxieData, numberOfStream, browserStatus);
      sendPort!.send(clone);

      await driver.get('https://www.tiktok.com');
      sleep(const Duration(milliseconds: 2500));
      await SelectInPage.refusedCookieAsked(driver);

      await goToSubscribeIfAccountNotSubscribe();
      await goToLoginPage(wasBlocked);
      await connectAccountToTiktok();
      await streamWhileNonStop();
    } catch (e) {
      chromeDriverProcess.kill();
      log(e.toString());
      sendStreamingInformation();
    }
  }

  Future<void> goToLoginPage(bool wasBlocked) async {
    var url = driver.currentUrl.toString();

    if (url.contains("redirect_url")) {
      await loginForRedirect(wasBlocked);
    } else {
      var element = await driver
          .findElement(const By.xpath("//*[@id=\"header-login-button\"]"));
      await element.click();

      var loginButtonInContainer = await driver.findElement(
          const By.xpath("//*[@id=\"loginContainer\"]/div/div/div/div[2]"));
      await loginButtonInContainer.click();
    }
  }

  Future<void> connectAccountToTiktok() async {
    if (await FindInPage.connexionPageIsPresent(driver)) {
      await fillConnexionField();
    } else {
      await driver
          .findElement(
              By.xpath("//*[@id=\"loginContainer\"]/div/form/div[1]/a"))
          .then((elem) async => await elem.click());

      if (await FindInPage.weAreOnPhoneAccountCreation(driver)) {
        await driver
            .findElement(
                By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/div[1]/a"))
            .then((elem) async => await elem.click());
      }
      await fillConnexionField();
    }
  }

  Future<void> streamWhileNonStop() async {
    math.Random randomNumber = math.Random();

    while (true) {
      int trendToSearch = randomNumber.nextInt(1) + tikTokTrends.length - 1;
      int videoToSelect = randomNumber.nextInt(6) + 1;
      await searchVideoOnSearchbar(trendToSearch);
      log("Video to Select $videoToSelect");

      await waitWhileCaptchaPresentWhileStreaming(wasBlocked);

      sleep(const Duration(milliseconds: 5000));

      await SelectInPage.selectAVideo(driver, videoToSelect);
      await waitWhileCaptchaPresentWhileConnecting(wasBlocked);
      await waitWhileCodeVerificationIsPresent(wasBlocked);
      await streamVideo();
    }
  }

  Future<void> searchVideoOnSearchbar(int trendToSearch) async {
    await driver
        .findElement(
            const By.xpath("//*[@id=\"app-header\"]/div/div[2]/div/form/input"))
        .then((elem) => elem.sendKeys(tikTokTrends[trendToSearch]));
    await driver
        .findElement(const By.xpath(
            "//*[@id=\"app-header\"]/div/div[2]/div/form/button"))
        .then((elem) => elem.click());
  }

  Future<void> streamVideo() async {
    math.Random randomNumber = math.Random();
    int waitBetweenNextVideo = randomNumber.nextInt(30) + 5;
    int numberOfVideoToWatch = randomNumber.nextInt(2) + 3;

    for (int i = 0; i < numberOfVideoToWatch; i++) {
      sleep(Duration(seconds: waitBetweenNextVideo));
      await waitWhileCaptchaPresentWhileStreaming(wasBlocked);
      await waitWhileCodeVerificationIsPresent(wasBlocked);

      await driver
          .findElement(const By.xpath(
              "//*[@id=\"tabs-0-panel-search_top\"]/div[3]/div/div[1]/button[3]"))
          .then((e) => e.click())
          .then((e) => log("J'ai cliqué poto")); // next video

      log("Await driver");
      await waitWhileCaptchaPresentWhileStreaming(wasBlocked);
      await waitWhileCodeVerificationIsPresent(wasBlocked);
      log("Finished waiting for captacha");

      numberOfStream += 1;
      sendStreamingInformation();
    }
    log("Go out");
    await driver
        .findElement(const By.xpath(
            "//*[@id=\"tabs-0-panel-search_top\"]/div[3]/div/div[1]/button[1]"))
        .then((e) => e.click());
    await waitWhileCaptchaPresentWhileStreaming(wasBlocked);
    await waitWhileCodeVerificationIsPresent(wasBlocked);
  }

  Future<void> goToSubscribeIfAccountNotSubscribe() async {
    if (account.status == Status.unsubscribe) {
      await driver
          .findElement(
              const By.xpath("//*[@id=\"login-modal\"]/div[1]/div[2]/a"))
          .then((link) => link.click());
      await driver
          .findElement(const By.xpath(
              "//*[@id=\"loginContainer\"]/div[2]/div/div/div[2]/div[1]/div[2]"))
          .then((link) => link.click());

      await fillBirthDateFields(driver);
      await SelectInPage.selectSubscriptionByEmail(driver);

      await driver
          .findElement(const By.xpath(
              "//*[@id=\"loginContainer\"]/div[2]/form/div[5]/div/input"))
          .then((element) => element.sendKeys(account.email));
      await driver
          .findElement(const By.xpath(
              "//*[@id=\"loginContainer\"]/div[2]/form/div[6]/div/input"))
          .then((element) => element.sendKeys(account.password));
      await driver
          .findElement(const By.xpath(
              "//*[@id=\"loginContainer\"]/div[2]/form/div[7]/div/button"))
          .then((element) => element.click());

      await recupererLeCodeRecuParMail();
      //Year

      await driver
          .findElement(const By.xpath(
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
    waitWhileCaptchaPresentWhileConnecting(wasBlocked);
    waitWhileCodeVerificationIsPresent(wasBlocked);
    sleep(const Duration(milliseconds: 1500));
    driver.get("https://www.tiktok.com/search");
  }

  Future<void> fillConnexionField() async {
    try {
      sleep(Duration(milliseconds: 2500));

      var loginInput = await driver.findElement(const By.xpath(
          "//*[@id=\"loginContainer\"]/div[2]/form/div[1]/input"));

      await loginInput.sendKeys(account.email);

      var passwordInput = await driver.findElement(const By.xpath(
          "//*[@id=\"loginContainer\"]/div[2]/form/div[2]/div/input"));
      await passwordInput.sendKeys(account.password);
      log("Passwordmec");

      var loginButton = await driver.findElement(
          const By.xpath("//*[@id=\"loginContainer\"]/div[2]/form/button"));
      await loginButton.click();
      log("LoginButtin");

      await waitWhileCaptchaPresentWhileConnecting(wasBlocked);
      await waitWhileCodeVerificationIsPresent(wasBlocked);
    } on Exception {
      log("Exception");
    }
  }

  Future<void> waitWhileCaptchaPresentWhileConnecting(bool wasBlocked) async {
    while (await FindInPage.captchaIsAskedWhileConnecting(driver)) {
      browserStatus = BrowserStatus.Captcha;
      if (!wasBlocked) {
        sendStreamingInformation();
      }
      sleep(const Duration(milliseconds: 1500));
      wasBlocked = true;
    }
    if (wasBlocked) {
      browserStatus = BrowserStatus.Running;
      sendStreamingInformation();
    }

    wasBlocked = false;
  }

  Future<void> waitWhileCaptchaPresentWhileStreaming(bool wasBlocked) async {
    while (await FindInPage.captchaIsAskedWhileStreaming(driver)) {
      browserStatus = BrowserStatus.Captcha;
      if (!wasBlocked) {
        sendStreamingInformation();
      }
      sleep(const Duration(milliseconds: 1500));
      wasBlocked = true;
      log("waitWhileCaptchaPresentWhileStreaming");
    }
    if (wasBlocked) {
      browserStatus = BrowserStatus.Running;
      sendStreamingInformation();
    }

    wasBlocked = false;
  }

  Future<void> waitWhileCodeVerificationIsPresent(bool wasBlocked) async {
    while (await FindInPage.verificationCodeIsAsked(driver)) {
      browserStatus = BrowserStatus.Captcha;
      if (!wasBlocked) {
        sendStreamingInformation();
      }
      sleep(const Duration(milliseconds: 1500));
      wasBlocked = true;
    }
    if (wasBlocked) {
      log("Verification Was blocked");
      wasBlocked = false;
      browserStatus = BrowserStatus.Running;
      sendStreamingInformation();
    }
  }

  Future<void> fillBirthDateFields(WebDriver _webDriver) async {
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

  @override
  String toString() {
    return 'Streamer{accountData: $account, proxieData: $proxieData, numberOfStream: $numberOfStream, browserStatus: $browserStatus, accountIsSubscribed: ${account.status}, wasBlocked: $wasBlocked}';
  }

  Future<String> recupererLeCodeRecuParMail() async {
    var code = await fetchInbox(account.email);
    log(code.toString());
    return code.body;
  }

  void sendStreamingInformation() {
    var clone =
        Streamer.clone(account, proxieData, numberOfStream, browserStatus);
    sendPort!.send(clone);
  }
}
