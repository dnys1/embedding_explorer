import 'package:jaspr/jaspr.dart';

import '../../util/clsx.dart';

class FaIconData {
  const FaIconData(this.type, this.name);

  factory FaIconData.fromJson(Map<String, dynamic> json) =>
      FaIconData(json['type'] as String, json['name'] as String);

  final String type;
  final String name;

  const FaIconData.solid(this.name) : type = 'solid';
  const FaIconData.regular(this.name) : type = 'regular';
  const FaIconData.brand(this.name) : type = 'brands';

  Map<String, dynamic> toJson() => {'type': type, 'name': name};
}

class FaIcon extends StatelessComponent {
  const FaIcon(this.iconData, {super.key, this.className, this.size = 16});

  final FaIconData iconData;
  final int size;
  final String? className;

  @override
  Component build(BuildContext context) {
    return i(
      classes: ['fa-${iconData.type}', 'fa-${iconData.name}', className].clsx,
      styles: Styles(fontSize: size.px),
      [],
    );
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
  FaIconData get home => const FaIconData.solid('home');
  FaIconData get menu => const FaIconData.solid('bars');
  FaIconData get close => const FaIconData.solid('xmark');
  FaIconData get search => const FaIconData.solid('magnifying-glass');
  FaIconData get filter => const FaIconData.solid('filter');
  FaIconData get sort => const FaIconData.solid('sort');
  FaIconData get chevronUp => const FaIconData.solid('chevron-up');
  FaIconData get chevronDown => const FaIconData.solid('chevron-down');
  FaIconData get chevronLeft => const FaIconData.solid('chevron-left');
  FaIconData get chevronRight => const FaIconData.solid('chevron-right');
  FaIconData get arrowUp => const FaIconData.solid('arrow-up');
  FaIconData get arrowDown => const FaIconData.solid('arrow-down');
  FaIconData get arrowLeft => const FaIconData.solid('arrow-left');
  FaIconData get arrowRight => const FaIconData.solid('arrow-right');
  FaIconData get caret => const FaIconData.solid('caret-down');
  FaIconData get caretUp => const FaIconData.solid('caret-up');
  FaIconData get caretLeft => const FaIconData.solid('caret-left');
  FaIconData get caretRight => const FaIconData.solid('caret-right');
  FaIconData get ellipsisVertical =>
      const FaIconData.solid('ellipsis-vertical');

  // Users & People
  FaIconData get user => const FaIconData.solid('user');
  FaIconData get users => const FaIconData.solid('users');
  FaIconData get userPlus => const FaIconData.solid('user-plus');
  FaIconData get userMinus => const FaIconData.solid('user-minus');
  FaIconData get userCircle => const FaIconData.solid('circle-user');
  FaIconData get userGroup => const FaIconData.solid('user-group');

  // Actions & Controls
  FaIconData get play => const FaIconData.solid('play');
  FaIconData get pause => const FaIconData.solid('pause');
  FaIconData get stop => const FaIconData.solid('stop');
  FaIconData get refresh => const FaIconData.solid('rotate-right');
  FaIconData get reload => const FaIconData.solid('arrows-rotate');
  FaIconData get sync => const FaIconData.solid('sync');
  FaIconData get undo => const FaIconData.solid('undo');
  FaIconData get redo => const FaIconData.solid('redo');
  FaIconData get copy => const FaIconData.solid('copy');
  FaIconData get paste => const FaIconData.solid('paste');
  FaIconData get cut => const FaIconData.solid('scissors');
  FaIconData get save => const FaIconData.solid('floppy-disk');
  FaIconData get download => const FaIconData.solid('download');
  FaIconData get upload => const FaIconData.solid('upload');
  FaIconData get share => const FaIconData.solid('share');
  FaIconData get export => const FaIconData.solid('file-export');
  FaIconData get import => const FaIconData.solid('file-import');

  // Editing & Content
  FaIconData get edit => const FaIconData.solid('pen');
  FaIconData get editAlt => const FaIconData.solid('pen-to-square');
  FaIconData get delete => const FaIconData.solid('trash');
  FaIconData get add => const FaIconData.solid('plus');
  FaIconData get remove => const FaIconData.solid('minus');
  FaIconData get create => const FaIconData.solid('plus-circle');
  FaIconData get clone => const FaIconData.solid('clone');
  FaIconData get duplicate => const FaIconData.solid('copy');

  // Files & Documents
  FaIconData get file => const FaIconData.solid('file');
  FaIconData get fileText => const FaIconData.solid('file-lines');
  FaIconData get fileCode => const FaIconData.solid('file-code');
  FaIconData get fileImage => const FaIconData.solid('file-image');
  FaIconData get filePdf => const FaIconData.solid('file-pdf');
  FaIconData get fileWord => const FaIconData.solid('file-word');
  FaIconData get fileExcel => const FaIconData.solid('file-excel');
  FaIconData get filePowerpoint => const FaIconData.solid('file-powerpoint');
  FaIconData get fileArchive => const FaIconData.solid('file-zipper');
  FaIconData get folder => const FaIconData.solid('folder');
  FaIconData get folderOpen => const FaIconData.solid('folder-open');
  FaIconData get folderPlus => const FaIconData.solid('folder-plus');

  // Communication
  FaIconData get email => const FaIconData.solid('envelope');
  FaIconData get emailOpen => const FaIconData.solid('envelope-open');
  FaIconData get message => const FaIconData.solid('message');
  FaIconData get comment => const FaIconData.solid('comment');
  FaIconData get comments => const FaIconData.solid('comments');
  FaIconData get chat => const FaIconData.solid('comment-dots');
  FaIconData get phone => const FaIconData.solid('phone');
  FaIconData get mobile => const FaIconData.solid('mobile-screen');

  // Settings & Configuration
  FaIconData get settings => const FaIconData.solid('gear');
  FaIconData get cog => const FaIconData.solid('cog');
  FaIconData get wrench => const FaIconData.solid('wrench');
  FaIconData get tools => const FaIconData.solid('screwdriver-wrench');
  FaIconData get sliders => const FaIconData.solid('sliders');
  FaIconData get hammer => const FaIconData.solid('hammer');

  // Status & Notifications
  FaIconData get info => const FaIconData.solid('circle-info');
  FaIconData get warning => const FaIconData.solid('triangle-exclamation');
  FaIconData get error => const FaIconData.solid('circle-exclamation');
  FaIconData get success => const FaIconData.solid('circle-check');
  FaIconData get check => const FaIconData.solid('check');
  FaIconData get times => const FaIconData.solid('xmark');
  FaIconData get question => const FaIconData.solid('circle-question');
  FaIconData get bell => const FaIconData.solid('bell');
  FaIconData get bellSlash => const FaIconData.solid('bell-slash');
  FaIconData get flag => const FaIconData.solid('flag');

  // Media & Graphics
  FaIconData get image => const FaIconData.solid('image');
  FaIconData get images => const FaIconData.solid('images');
  FaIconData get camera => const FaIconData.solid('camera');
  FaIconData get video => const FaIconData.solid('video');
  FaIconData get film => const FaIconData.solid('film');
  FaIconData get music => const FaIconData.solid('music');
  FaIconData get volumeHigh => const FaIconData.solid('volume-high');
  FaIconData get volumeLow => const FaIconData.solid('volume-low');
  FaIconData get volumeMute => const FaIconData.solid('volume-xmark');

  // Security & Lock
  FaIconData get lock => const FaIconData.solid('lock');
  FaIconData get unlock => const FaIconData.solid('unlock');
  FaIconData get key => const FaIconData.solid('key');
  FaIconData get shield => const FaIconData.solid('shield-halved');
  FaIconData get eye => const FaIconData.solid('eye');
  FaIconData get eyeSlash => const FaIconData.solid('eye-slash');

  // Time & Calendar
  FaIconData get calendar => const FaIconData.solid('calendar');
  FaIconData get calendarDay => const FaIconData.solid('calendar-day');
  FaIconData get calendarWeek => const FaIconData.solid('calendar-week');
  FaIconData get clock => const FaIconData.solid('clock');
  FaIconData get stopwatch => const FaIconData.solid('stopwatch');
  FaIconData get history => const FaIconData.solid('clock-rotate-left');

  // Layout & View
  FaIconData get list => const FaIconData.solid('list');
  FaIconData get listUl => const FaIconData.solid('list-ul');
  FaIconData get listOl => const FaIconData.solid('list-ol');
  FaIconData get grid => const FaIconData.solid('grid');
  FaIconData get table => const FaIconData.solid('table');
  FaIconData get columns => const FaIconData.solid('columns');
  FaIconData get expand => const FaIconData.solid('expand');
  FaIconData get compress => const FaIconData.solid('compress');
  FaIconData get fullscreen => const FaIconData.solid('expand');
  FaIconData get exitFullscreen => const FaIconData.solid('compress');

  // Data & Analytics
  FaIconData get chartBar => const FaIconData.solid('chart-column');
  FaIconData get chartLine => const FaIconData.solid('chart-line');
  FaIconData get chartPie => const FaIconData.solid('chart-pie');
  FaIconData get database => const FaIconData.solid('database');
  FaIconData get server => const FaIconData.solid('server');
  FaIconData get cloudStorage => const FaIconData.solid('cloud');
  FaIconData get cloudDownload => const FaIconData.solid('cloud-arrow-down');
  FaIconData get cloudUpload => const FaIconData.solid('cloud-arrow-up');

  // Shopping & Commerce
  FaIconData get shoppingCart => const FaIconData.solid('cart-shopping');
  FaIconData get shoppingBag => const FaIconData.solid('bag-shopping');
  FaIconData get creditCard => const FaIconData.solid('credit-card');
  FaIconData get money => const FaIconData.solid('dollar-sign');
  FaIconData get tag => const FaIconData.solid('tag');
  FaIconData get tags => const FaIconData.solid('tags');

  // Location & Maps
  FaIconData get map => const FaIconData.solid('map');
  FaIconData get mapPin => const FaIconData.solid('location-dot');
  FaIconData get compass => const FaIconData.solid('compass');
  FaIconData get globe => const FaIconData.solid('globe');
  FaIconData get locationArrow => const FaIconData.solid('location-arrow');

  // Transport
  FaIconData get car => const FaIconData.solid('car');
  FaIconData get plane => const FaIconData.solid('plane');
  FaIconData get train => const FaIconData.solid('train');
  FaIconData get ship => const FaIconData.solid('ship');
  FaIconData get bicycle => const FaIconData.solid('bicycle');

  // Weather
  FaIconData get sun => const FaIconData.solid('sun');
  FaIconData get moon => const FaIconData.solid('moon');
  FaIconData get cloud => const FaIconData.solid('cloud');
  FaIconData get cloudRain => const FaIconData.solid('cloud-rain');
  FaIconData get cloudSnow => const FaIconData.solid('cloud-snow');
  FaIconData get bolt => const FaIconData.solid('bolt');

  // Gaming & Entertainment
  FaIconData get gamepad => const FaIconData.solid('gamepad');
  FaIconData get dice => const FaIconData.solid('dice');
  FaIconData get puzzle => const FaIconData.solid('puzzle-piece');
  FaIconData get trophy => const FaIconData.solid('trophy');
  FaIconData get medal => const FaIconData.solid('medal');
  FaIconData get award => const FaIconData.solid('award');

  // Health & Medical
  FaIconData get heart => const FaIconData.solid('heart');
  FaIconData get plus => const FaIconData.solid('plus');
  FaIconData get pills => const FaIconData.solid('pills');
  FaIconData get syringe => const FaIconData.solid('syringe');
  FaIconData get stethoscope => const FaIconData.solid('stethoscope');

  // Technology & Development
  FaIconData get code => const FaIconData.solid('code');
  FaIconData get terminal => const FaIconData.solid('terminal');
  FaIconData get bug => const FaIconData.solid('bug');
  FaIconData get laptop => const FaIconData.solid('laptop');
  FaIconData get desktop => const FaIconData.solid('desktop');
  FaIconData get mobileDevice => const FaIconData.solid('mobile-screen');
  FaIconData get wifi => const FaIconData.solid('wifi');
  FaIconData get bluetooth => const FaIconData.solid('bluetooth');
  FaIconData get usb => const FaIconData.solid('usb');

  // Misc Symbols
  FaIconData get star => const FaIconData.solid('star');
  FaIconData get bookmark => const FaIconData.solid('bookmark');
  FaIconData get thumbsUp => const FaIconData.solid('thumbs-up');
  FaIconData get thumbsDown => const FaIconData.solid('thumbs-down');
  FaIconData get lightbulb => const FaIconData.solid('lightbulb');
  FaIconData get fire => const FaIconData.solid('fire');
  FaIconData get magicWand => const FaIconData.solid('wand-magic-sparkles');
  FaIconData get rainbow => const FaIconData.solid('rainbow');
}

class FaRegularIcons {
  const FaRegularIcons();

  // Common regular icons
  FaIconData get user => const FaIconData.regular('user');
  FaIconData get envelope => const FaIconData.regular('envelope');
  FaIconData get file => const FaIconData.regular('file');
  FaIconData get folder => const FaIconData.regular('folder');
  FaIconData get folderOpen => const FaIconData.regular('folder-open');
  FaIconData get heart => const FaIconData.regular('heart');
  FaIconData get star => const FaIconData.regular('star');
  FaIconData get bookmark => const FaIconData.regular('bookmark');
  FaIconData get clock => const FaIconData.regular('clock');
  FaIconData get calendar => const FaIconData.regular('calendar');
  FaIconData get calendarAlt => const FaIconData.regular('calendar-days');
  FaIconData get comment => const FaIconData.regular('comment');
  FaIconData get comments => const FaIconData.regular('comments');
  FaIconData get thumbsUp => const FaIconData.regular('thumbs-up');
  FaIconData get thumbsDown => const FaIconData.regular('thumbs-down');
  FaIconData get lightbulb => const FaIconData.regular('lightbulb');
  FaIconData get bell => const FaIconData.regular('bell');
  FaIconData get flag => const FaIconData.regular('flag');
  FaIconData get image => const FaIconData.regular('image');
  FaIconData get images => const FaIconData.regular('images');
  FaIconData get eye => const FaIconData.regular('eye');
  FaIconData get eyeSlash => const FaIconData.regular('eye-slash');
  FaIconData get circle => const FaIconData.regular('circle');
  FaIconData get circleCheck => const FaIconData.regular('circle-check');
  FaIconData get circleDot => const FaIconData.regular('circle-dot');
  FaIconData get square => const FaIconData.regular('square');
  FaIconData get squareCheck => const FaIconData.regular('square-check');
  FaIconData get clipboard => const FaIconData.regular('clipboard');
  FaIconData get copy => const FaIconData.regular('copy');
  FaIconData get edit => const FaIconData.regular('pen-to-square');
  FaIconData get trash => const FaIconData.regular('trash-can');
  FaIconData get handPaper => const FaIconData.regular('hand');
}

class FaBrandIcons {
  const FaBrandIcons();

  // Social Media
  FaIconData get facebook => const FaIconData.brand('facebook');
  FaIconData get twitter => const FaIconData.brand('twitter');
  FaIconData get instagram => const FaIconData.brand('instagram');
  FaIconData get linkedin => const FaIconData.brand('linkedin');
  FaIconData get youtube => const FaIconData.brand('youtube');
  FaIconData get tiktok => const FaIconData.brand('tiktok');
  FaIconData get snapchat => const FaIconData.brand('snapchat');
  FaIconData get pinterest => const FaIconData.brand('pinterest');
  FaIconData get reddit => const FaIconData.brand('reddit');
  FaIconData get discord => const FaIconData.brand('discord');
  FaIconData get telegram => const FaIconData.brand('telegram');
  FaIconData get whatsapp => const FaIconData.brand('whatsapp');

  // Technology Companies
  FaIconData get google => const FaIconData.brand('google');
  FaIconData get microsoft => const FaIconData.brand('microsoft');
  FaIconData get apple => const FaIconData.brand('apple');
  FaIconData get amazon => const FaIconData.brand('amazon');
  FaIconData get meta => const FaIconData.brand('meta');
  FaIconData get netflix => const FaIconData.brand('netflix');
  FaIconData get spotify => const FaIconData.brand('spotify');
  FaIconData get uber => const FaIconData.brand('uber');
  FaIconData get airbnb => const FaIconData.brand('airbnb');

  // Development & Tools
  FaIconData get github => const FaIconData.brand('github');
  FaIconData get gitlab => const FaIconData.brand('gitlab');
  FaIconData get bitbucket => const FaIconData.brand('bitbucket');
  FaIconData get stackoverflow => const FaIconData.brand('stack-overflow');
  FaIconData get npm => const FaIconData.brand('npm');
  FaIconData get docker => const FaIconData.brand('docker');
  FaIconData get jenkins => const FaIconData.brand('jenkins');
  FaIconData get jira => const FaIconData.brand('atlassian');
  FaIconData get slack => const FaIconData.brand('slack');
  FaIconData get trello => const FaIconData.brand('trello');
  FaIconData get figma => const FaIconData.brand('figma');
  FaIconData get sketch => const FaIconData.brand('sketch');
  FaIconData get adobe => const FaIconData.brand('adobe');
  FaIconData get openai => const FaIconData.brand('openai');

  // Operating Systems & Browsers
  FaIconData get windows => const FaIconData.brand('windows');
  FaIconData get linux => const FaIconData.brand('linux');
  FaIconData get ubuntu => const FaIconData.brand('ubuntu');
  FaIconData get chrome => const FaIconData.brand('chrome');
  FaIconData get firefox => const FaIconData.brand('firefox');
  FaIconData get safari => const FaIconData.brand('safari');
  FaIconData get edge => const FaIconData.brand('edge');

  // Programming Languages & Frameworks
  FaIconData get js => const FaIconData.brand('js');
  FaIconData get react => const FaIconData.brand('react');
  FaIconData get angular => const FaIconData.brand('angular');
  FaIconData get vue => const FaIconData.brand('vuejs');
  FaIconData get node => const FaIconData.brand('node-js');
  FaIconData get python => const FaIconData.brand('python');
  FaIconData get java => const FaIconData.brand('java');
  FaIconData get php => const FaIconData.brand('php');
  FaIconData get swift => const FaIconData.brand('swift');
  FaIconData get android => const FaIconData.brand('android');

  // Payment & Financial
  FaIconData get paypal => const FaIconData.brand('paypal');
  FaIconData get stripe => const FaIconData.brand('stripe');
  FaIconData get visa => const FaIconData.brand('cc-visa');
  FaIconData get mastercard => const FaIconData.brand('cc-mastercard');
  FaIconData get amex => const FaIconData.brand('cc-amex');
  FaIconData get bitcoin => const FaIconData.brand('bitcoin');

  // Gaming Platforms
  FaIconData get steam => const FaIconData.brand('steam');
  FaIconData get playstation => const FaIconData.brand('playstation');
  FaIconData get xbox => const FaIconData.brand('xbox');
  FaIconData get nintendo => const FaIconData.brand('nintendo-switch');
  FaIconData get twitch => const FaIconData.brand('twitch');

  // Communication & Productivity
  FaIconData get zoom => const FaIconData.brand('zoom');
  FaIconData get teams => const FaIconData.brand('microsoft');
  FaIconData get skype => const FaIconData.brand('skype');
  FaIconData get dropbox => const FaIconData.brand('dropbox');
  FaIconData get googleDrive => const FaIconData.brand('google-drive');
}
