import 'package:jaspr/jaspr.dart';

class FaIcon extends StatelessComponent {
  final String type;
  final String name;

  const FaIcon(this.type, this.name);

  const FaIcon.solid(this.name) : type = 'solid';
  const FaIcon.regular(this.name) : type = 'regular';
  const FaIcon.brand(this.name) : type = 'brands';

  String get classes => 'fa-$type fa-$name';

  @override
  Component build(BuildContext context) {
    return Component.element(tag: 'i', classes: classes);
  }
}

abstract final class FaIcons {
  static const FaSolidIcons solid = FaSolidIcons();
  static const FaRegularIcons regular = FaRegularIcons();
  static const FaBrandIcons brands = FaBrandIcons();
}

class FaSolidIcons {
  const FaSolidIcons();

  // Navigation & UI
  FaIcon get home => const FaIcon.solid('home');
  FaIcon get menu => const FaIcon.solid('bars');
  FaIcon get close => const FaIcon.solid('xmark');
  FaIcon get search => const FaIcon.solid('magnifying-glass');
  FaIcon get filter => const FaIcon.solid('filter');
  FaIcon get sort => const FaIcon.solid('sort');
  FaIcon get chevronUp => const FaIcon.solid('chevron-up');
  FaIcon get chevronDown => const FaIcon.solid('chevron-down');
  FaIcon get chevronLeft => const FaIcon.solid('chevron-left');
  FaIcon get chevronRight => const FaIcon.solid('chevron-right');
  FaIcon get arrowUp => const FaIcon.solid('arrow-up');
  FaIcon get arrowDown => const FaIcon.solid('arrow-down');
  FaIcon get arrowLeft => const FaIcon.solid('arrow-left');
  FaIcon get arrowRight => const FaIcon.solid('arrow-right');
  FaIcon get caret => const FaIcon.solid('caret-down');
  FaIcon get caretUp => const FaIcon.solid('caret-up');
  FaIcon get caretLeft => const FaIcon.solid('caret-left');
  FaIcon get caretRight => const FaIcon.solid('caret-right');

  // Users & People
  FaIcon get user => const FaIcon.solid('user');
  FaIcon get users => const FaIcon.solid('users');
  FaIcon get userPlus => const FaIcon.solid('user-plus');
  FaIcon get userMinus => const FaIcon.solid('user-minus');
  FaIcon get userCircle => const FaIcon.solid('circle-user');
  FaIcon get userGroup => const FaIcon.solid('user-group');

  // Actions & Controls
  FaIcon get play => const FaIcon.solid('play');
  FaIcon get pause => const FaIcon.solid('pause');
  FaIcon get stop => const FaIcon.solid('stop');
  FaIcon get refresh => const FaIcon.solid('rotate-right');
  FaIcon get reload => const FaIcon.solid('arrows-rotate');
  FaIcon get sync => const FaIcon.solid('sync');
  FaIcon get undo => const FaIcon.solid('undo');
  FaIcon get redo => const FaIcon.solid('redo');
  FaIcon get copy => const FaIcon.solid('copy');
  FaIcon get paste => const FaIcon.solid('paste');
  FaIcon get cut => const FaIcon.solid('scissors');
  FaIcon get save => const FaIcon.solid('floppy-disk');
  FaIcon get download => const FaIcon.solid('download');
  FaIcon get upload => const FaIcon.solid('upload');
  FaIcon get share => const FaIcon.solid('share');
  FaIcon get export => const FaIcon.solid('file-export');
  FaIcon get import => const FaIcon.solid('file-import');

  // Editing & Content
  FaIcon get edit => const FaIcon.solid('pen');
  FaIcon get editAlt => const FaIcon.solid('pen-to-square');
  FaIcon get delete => const FaIcon.solid('trash');
  FaIcon get add => const FaIcon.solid('plus');
  FaIcon get remove => const FaIcon.solid('minus');
  FaIcon get create => const FaIcon.solid('plus-circle');
  FaIcon get clone => const FaIcon.solid('clone');
  FaIcon get duplicate => const FaIcon.solid('copy');

  // Files & Documents
  FaIcon get file => const FaIcon.solid('file');
  FaIcon get fileText => const FaIcon.solid('file-lines');
  FaIcon get fileCode => const FaIcon.solid('file-code');
  FaIcon get fileImage => const FaIcon.solid('file-image');
  FaIcon get filePdf => const FaIcon.solid('file-pdf');
  FaIcon get fileWord => const FaIcon.solid('file-word');
  FaIcon get fileExcel => const FaIcon.solid('file-excel');
  FaIcon get filePowerpoint => const FaIcon.solid('file-powerpoint');
  FaIcon get fileArchive => const FaIcon.solid('file-zipper');
  FaIcon get folder => const FaIcon.solid('folder');
  FaIcon get folderOpen => const FaIcon.solid('folder-open');
  FaIcon get folderPlus => const FaIcon.solid('folder-plus');

  // Communication
  FaIcon get email => const FaIcon.solid('envelope');
  FaIcon get emailOpen => const FaIcon.solid('envelope-open');
  FaIcon get message => const FaIcon.solid('message');
  FaIcon get comment => const FaIcon.solid('comment');
  FaIcon get comments => const FaIcon.solid('comments');
  FaIcon get chat => const FaIcon.solid('comment-dots');
  FaIcon get phone => const FaIcon.solid('phone');
  FaIcon get mobile => const FaIcon.solid('mobile-screen');

  // Settings & Configuration
  FaIcon get settings => const FaIcon.solid('gear');
  FaIcon get cog => const FaIcon.solid('cog');
  FaIcon get wrench => const FaIcon.solid('wrench');
  FaIcon get tools => const FaIcon.solid('screwdriver-wrench');
  FaIcon get sliders => const FaIcon.solid('sliders');

  // Status & Notifications
  FaIcon get info => const FaIcon.solid('circle-info');
  FaIcon get warning => const FaIcon.solid('triangle-exclamation');
  FaIcon get error => const FaIcon.solid('circle-exclamation');
  FaIcon get success => const FaIcon.solid('circle-check');
  FaIcon get check => const FaIcon.solid('check');
  FaIcon get times => const FaIcon.solid('xmark');
  FaIcon get question => const FaIcon.solid('circle-question');
  FaIcon get bell => const FaIcon.solid('bell');
  FaIcon get bellSlash => const FaIcon.solid('bell-slash');
  FaIcon get flag => const FaIcon.solid('flag');

  // Media & Graphics
  FaIcon get image => const FaIcon.solid('image');
  FaIcon get images => const FaIcon.solid('images');
  FaIcon get camera => const FaIcon.solid('camera');
  FaIcon get video => const FaIcon.solid('video');
  FaIcon get film => const FaIcon.solid('film');
  FaIcon get music => const FaIcon.solid('music');
  FaIcon get volumeHigh => const FaIcon.solid('volume-high');
  FaIcon get volumeLow => const FaIcon.solid('volume-low');
  FaIcon get volumeMute => const FaIcon.solid('volume-xmark');

  // Security & Lock
  FaIcon get lock => const FaIcon.solid('lock');
  FaIcon get unlock => const FaIcon.solid('unlock');
  FaIcon get key => const FaIcon.solid('key');
  FaIcon get shield => const FaIcon.solid('shield-halved');
  FaIcon get eye => const FaIcon.solid('eye');
  FaIcon get eyeSlash => const FaIcon.solid('eye-slash');

  // Time & Calendar
  FaIcon get calendar => const FaIcon.solid('calendar');
  FaIcon get calendarDay => const FaIcon.solid('calendar-day');
  FaIcon get calendarWeek => const FaIcon.solid('calendar-week');
  FaIcon get clock => const FaIcon.solid('clock');
  FaIcon get stopwatch => const FaIcon.solid('stopwatch');
  FaIcon get history => const FaIcon.solid('clock-rotate-left');

  // Layout & View
  FaIcon get list => const FaIcon.solid('list');
  FaIcon get listUl => const FaIcon.solid('list-ul');
  FaIcon get listOl => const FaIcon.solid('list-ol');
  FaIcon get grid => const FaIcon.solid('grid');
  FaIcon get table => const FaIcon.solid('table');
  FaIcon get columns => const FaIcon.solid('columns');
  FaIcon get expand => const FaIcon.solid('expand');
  FaIcon get compress => const FaIcon.solid('compress');
  FaIcon get fullscreen => const FaIcon.solid('expand');
  FaIcon get exitFullscreen => const FaIcon.solid('compress');

  // Data & Analytics
  FaIcon get chartBar => const FaIcon.solid('chart-column');
  FaIcon get chartLine => const FaIcon.solid('chart-line');
  FaIcon get chartPie => const FaIcon.solid('chart-pie');
  FaIcon get database => const FaIcon.solid('database');
  FaIcon get server => const FaIcon.solid('server');
  FaIcon get cloudStorage => const FaIcon.solid('cloud');
  FaIcon get cloudDownload => const FaIcon.solid('cloud-arrow-down');
  FaIcon get cloudUpload => const FaIcon.solid('cloud-arrow-up');

  // Shopping & Commerce
  FaIcon get shoppingCart => const FaIcon.solid('cart-shopping');
  FaIcon get shoppingBag => const FaIcon.solid('bag-shopping');
  FaIcon get creditCard => const FaIcon.solid('credit-card');
  FaIcon get money => const FaIcon.solid('dollar-sign');
  FaIcon get tag => const FaIcon.solid('tag');
  FaIcon get tags => const FaIcon.solid('tags');

  // Location & Maps
  FaIcon get map => const FaIcon.solid('map');
  FaIcon get mapPin => const FaIcon.solid('location-dot');
  FaIcon get compass => const FaIcon.solid('compass');
  FaIcon get globe => const FaIcon.solid('globe');
  FaIcon get locationArrow => const FaIcon.solid('location-arrow');

  // Transport
  FaIcon get car => const FaIcon.solid('car');
  FaIcon get plane => const FaIcon.solid('plane');
  FaIcon get train => const FaIcon.solid('train');
  FaIcon get ship => const FaIcon.solid('ship');
  FaIcon get bicycle => const FaIcon.solid('bicycle');

  // Weather
  FaIcon get sun => const FaIcon.solid('sun');
  FaIcon get moon => const FaIcon.solid('moon');
  FaIcon get cloud => const FaIcon.solid('cloud');
  FaIcon get cloudRain => const FaIcon.solid('cloud-rain');
  FaIcon get cloudSnow => const FaIcon.solid('cloud-snow');
  FaIcon get bolt => const FaIcon.solid('bolt');

  // Gaming & Entertainment
  FaIcon get gamepad => const FaIcon.solid('gamepad');
  FaIcon get dice => const FaIcon.solid('dice');
  FaIcon get puzzle => const FaIcon.solid('puzzle-piece');
  FaIcon get trophy => const FaIcon.solid('trophy');
  FaIcon get medal => const FaIcon.solid('medal');
  FaIcon get award => const FaIcon.solid('award');

  // Health & Medical
  FaIcon get heart => const FaIcon.solid('heart');
  FaIcon get plus => const FaIcon.solid('plus');
  FaIcon get pills => const FaIcon.solid('pills');
  FaIcon get syringe => const FaIcon.solid('syringe');
  FaIcon get stethoscope => const FaIcon.solid('stethoscope');

  // Technology & Development
  FaIcon get code => const FaIcon.solid('code');
  FaIcon get terminal => const FaIcon.solid('terminal');
  FaIcon get bug => const FaIcon.solid('bug');
  FaIcon get laptop => const FaIcon.solid('laptop');
  FaIcon get desktop => const FaIcon.solid('desktop');
  FaIcon get mobileDevice => const FaIcon.solid('mobile-screen');
  FaIcon get wifi => const FaIcon.solid('wifi');
  FaIcon get bluetooth => const FaIcon.solid('bluetooth');
  FaIcon get usb => const FaIcon.solid('usb');

  // Misc Symbols
  FaIcon get star => const FaIcon.solid('star');
  FaIcon get bookmark => const FaIcon.solid('bookmark');
  FaIcon get thumbsUp => const FaIcon.solid('thumbs-up');
  FaIcon get thumbsDown => const FaIcon.solid('thumbs-down');
  FaIcon get lightbulb => const FaIcon.solid('lightbulb');
  FaIcon get fire => const FaIcon.solid('fire');
  FaIcon get magicWand => const FaIcon.solid('wand-magic-sparkles');
  FaIcon get rainbow => const FaIcon.solid('rainbow');
}

class FaRegularIcons {
  const FaRegularIcons();

  // Common regular icons
  FaIcon get user => const FaIcon.regular('user');
  FaIcon get envelope => const FaIcon.regular('envelope');
  FaIcon get file => const FaIcon.regular('file');
  FaIcon get folder => const FaIcon.regular('folder');
  FaIcon get folderOpen => const FaIcon.regular('folder-open');
  FaIcon get heart => const FaIcon.regular('heart');
  FaIcon get star => const FaIcon.regular('star');
  FaIcon get bookmark => const FaIcon.regular('bookmark');
  FaIcon get clock => const FaIcon.regular('clock');
  FaIcon get calendar => const FaIcon.regular('calendar');
  FaIcon get calendarAlt => const FaIcon.regular('calendar-days');
  FaIcon get comment => const FaIcon.regular('comment');
  FaIcon get comments => const FaIcon.regular('comments');
  FaIcon get thumbsUp => const FaIcon.regular('thumbs-up');
  FaIcon get thumbsDown => const FaIcon.regular('thumbs-down');
  FaIcon get lightbulb => const FaIcon.regular('lightbulb');
  FaIcon get bell => const FaIcon.regular('bell');
  FaIcon get flag => const FaIcon.regular('flag');
  FaIcon get image => const FaIcon.regular('image');
  FaIcon get images => const FaIcon.regular('images');
  FaIcon get eye => const FaIcon.regular('eye');
  FaIcon get eyeSlash => const FaIcon.regular('eye-slash');
  FaIcon get circle => const FaIcon.regular('circle');
  FaIcon get circleCheck => const FaIcon.regular('circle-check');
  FaIcon get circleDot => const FaIcon.regular('circle-dot');
  FaIcon get square => const FaIcon.regular('square');
  FaIcon get squareCheck => const FaIcon.regular('square-check');
  FaIcon get clipboard => const FaIcon.regular('clipboard');
  FaIcon get copy => const FaIcon.regular('copy');
  FaIcon get edit => const FaIcon.regular('pen-to-square');
  FaIcon get trash => const FaIcon.regular('trash-can');
  FaIcon get handPaper => const FaIcon.regular('hand');
}

class FaBrandIcons {
  const FaBrandIcons();

  // Social Media
  FaIcon get facebook => const FaIcon.brand('facebook');
  FaIcon get twitter => const FaIcon.brand('twitter');
  FaIcon get instagram => const FaIcon.brand('instagram');
  FaIcon get linkedin => const FaIcon.brand('linkedin');
  FaIcon get youtube => const FaIcon.brand('youtube');
  FaIcon get tiktok => const FaIcon.brand('tiktok');
  FaIcon get snapchat => const FaIcon.brand('snapchat');
  FaIcon get pinterest => const FaIcon.brand('pinterest');
  FaIcon get reddit => const FaIcon.brand('reddit');
  FaIcon get discord => const FaIcon.brand('discord');
  FaIcon get telegram => const FaIcon.brand('telegram');
  FaIcon get whatsapp => const FaIcon.brand('whatsapp');

  // Technology Companies
  FaIcon get google => const FaIcon.brand('google');
  FaIcon get microsoft => const FaIcon.brand('microsoft');
  FaIcon get apple => const FaIcon.brand('apple');
  FaIcon get amazon => const FaIcon.brand('amazon');
  FaIcon get meta => const FaIcon.brand('meta');
  FaIcon get netflix => const FaIcon.brand('netflix');
  FaIcon get spotify => const FaIcon.brand('spotify');
  FaIcon get uber => const FaIcon.brand('uber');
  FaIcon get airbnb => const FaIcon.brand('airbnb');

  // Development & Tools
  FaIcon get github => const FaIcon.brand('github');
  FaIcon get gitlab => const FaIcon.brand('gitlab');
  FaIcon get bitbucket => const FaIcon.brand('bitbucket');
  FaIcon get stackoverflow => const FaIcon.brand('stack-overflow');
  FaIcon get npm => const FaIcon.brand('npm');
  FaIcon get docker => const FaIcon.brand('docker');
  FaIcon get jenkins => const FaIcon.brand('jenkins');
  FaIcon get jira => const FaIcon.brand('atlassian');
  FaIcon get slack => const FaIcon.brand('slack');
  FaIcon get trello => const FaIcon.brand('trello');
  FaIcon get figma => const FaIcon.brand('figma');
  FaIcon get sketch => const FaIcon.brand('sketch');
  FaIcon get adobe => const FaIcon.brand('adobe');

  // Operating Systems & Browsers
  FaIcon get windows => const FaIcon.brand('windows');
  FaIcon get linux => const FaIcon.brand('linux');
  FaIcon get ubuntu => const FaIcon.brand('ubuntu');
  FaIcon get chrome => const FaIcon.brand('chrome');
  FaIcon get firefox => const FaIcon.brand('firefox');
  FaIcon get safari => const FaIcon.brand('safari');
  FaIcon get edge => const FaIcon.brand('edge');

  // Programming Languages & Frameworks
  FaIcon get js => const FaIcon.brand('js');
  FaIcon get react => const FaIcon.brand('react');
  FaIcon get angular => const FaIcon.brand('angular');
  FaIcon get vue => const FaIcon.brand('vuejs');
  FaIcon get node => const FaIcon.brand('node-js');
  FaIcon get python => const FaIcon.brand('python');
  FaIcon get java => const FaIcon.brand('java');
  FaIcon get php => const FaIcon.brand('php');
  FaIcon get swift => const FaIcon.brand('swift');
  FaIcon get android => const FaIcon.brand('android');

  // Payment & Financial
  FaIcon get paypal => const FaIcon.brand('paypal');
  FaIcon get stripe => const FaIcon.brand('stripe');
  FaIcon get visa => const FaIcon.brand('cc-visa');
  FaIcon get mastercard => const FaIcon.brand('cc-mastercard');
  FaIcon get amex => const FaIcon.brand('cc-amex');
  FaIcon get bitcoin => const FaIcon.brand('bitcoin');

  // Gaming Platforms
  FaIcon get steam => const FaIcon.brand('steam');
  FaIcon get playstation => const FaIcon.brand('playstation');
  FaIcon get xbox => const FaIcon.brand('xbox');
  FaIcon get nintendo => const FaIcon.brand('nintendo-switch');
  FaIcon get twitch => const FaIcon.brand('twitch');

  // Communication & Productivity
  FaIcon get zoom => const FaIcon.brand('zoom');
  FaIcon get teams => const FaIcon.brand('microsoft');
  FaIcon get skype => const FaIcon.brand('skype');
  FaIcon get dropbox => const FaIcon.brand('dropbox');
  FaIcon get googleDrive => const FaIcon.brand('google-drive');
}
