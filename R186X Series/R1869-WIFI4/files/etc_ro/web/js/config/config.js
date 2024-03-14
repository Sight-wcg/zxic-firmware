define(function(){var a={IS_TEST:web_ui_is_test,PRODUCT_TYPE:"UFI",HAS_LOGIN:true,LOGIN_THEN_CHECK_PIN:true,defaultRoute:"#login",LOGIN_SECURITY_SUPPORT:true,MAX_LOGIN_COUNT:5,GUEST_HASH:["#httpshare_guest"],INCLUDE_MOBILE:true,DEVICE:"ufi",PASSWORD_ENCODE:true,EMPTY_APN_SUPPORT:false,FAST_BOOT_SUPPORT:true,TURN_OFF_SUPPORT:false,HAS_CASCADE_SMS:true,HAS_FOTA:true,HAS_UPDATE_CHECK:true,ISNOW_NOTICE:false,HAS_MULTI_SSID:false,HAS_WIFI:true,HAS_BATTERY:false,SHOW_MAC_ADDRESS:false,IPV6_SUPPORT:true,IPV4V6_SUPPORT:true,IPV4_AND_V6_SUPPORT:false,TRAFFIC_SUPPORT:true,CLEAR_DATA_SUPPORT:false,MAX_STATION_NUMBER:32,NETWORK_UNLOCK_SUPPORT:false,WIFI_BAND_SUPPORT:false,WIFI_BANDWIDTH_SUPPORT:false,WIFI_BANDWIDTH_SUPPORT_40MHZ:false,WIFI_SUPPORT_QR_CODE:true,WIFI_SUPPORT_QR_SWITCH:false,WIFI_SWITCH_SUPPORT:true,WIFI_SLEEP_SUPPORT:false,WIFI_WEP_SUPPORT:false,WIFI_HAS_5G:false,SHOW_WIFI_AP_ISOLATED:false,STATION_BLOCK_SUPPORT:false,UPGRADE_TYPE:"FOTA",ALREADY_NOTICE:false,ALREADY_OTA_NOTICE:false,AP_STATION_SUPPORT:false,AP_STATION_LIST_LENGTH:10,TSW_SUPPORT:false,HAS_PHONEBOOK:true,HAS_SMS:true,SMS_DATABASE_SORT_SUPPORT:true,SHOW_UN_COMPLETE_CONCAT_SMS:true,SMS_UNREAD_NUM_INCLUDE_SIM:false,SMS_SET_READ_WHEN_COMPLETE:false,SMS_MATCH_LENGTH:11,SD_CARD_SUPPORT:false,WEBUI_TITLE:"4G Hostless Modem",TEMPORARY_MODEM_MAIN_STATE:["modem_undetected","modem_detected","modem_sim_state","modem_handover","modem_imsi_lock","modem_online","modem_offline"],SHOW_APN_DNS:false,HAS_PARENTAL_CONTROL:false,HAS_USSD:true,HAS_URL:false,connect_flag:false,RJ45_SUPPORT:false,HAS_QUICK_SETTING:true,HAS_SNTP:false,HAS_BLACK_AND_WHITE_FILTER:false,NATIVE_UPDATE_FILE_SIZE:64,DDNS_SUPPORT:true,CONTENT_MODIFIED:{modified:false,message:"leave_page_info",data:{},checkChangMethod:function(){return false},callback:{ok:$.noop,no:function(){return true}}},resetContentModifyValue:function(){this.CONTENT_MODIFIED.checkChangMethod=function(){return false};this.CONTENT_MODIFIED.modified=false;this.CONTENT_MODIFIED.message="leave_page_info";this.CONTENT_MODIFIED.callback={ok:$.noop,no:function(){return true}};this.CONTENT_MODIFIED.data={}},portForwardMax:10,urlFilterMax:10,REMO_SELECTSIM_MODE:[{name:"Auto",value:"auto"},{name:"Manual",value:"manual"}],REMO_SELECTSIM_NUM_ID0:[{name:"SIM1",value:"SIM1"}],REMO_SELECTSIM_NUM_ID1:[{name:"SIM1",value:"SIM1"},{name:"SIM2",value:"SIM2"}],REMO_SELECTSIM_NUM_ID2:[{name:"SIM1",value:"SIM1"},{name:"SIM2",value:"SIM2"}],REMO_SELECTSIM_NUM_ID3:[{name:"SIM1",value:"SIM1"},{name:"SIM2",value:"SIM2"},{name:"SIM3",value:"SIM3"}],REMO_SELECTALLSIM_NUM_ID0:[{name:"SIM0",value:"SIM0"}],REMO_SELECTALLSIM_NUM_ID1:[{name:"SIM0",value:"SIM0"},{name:"SIM1",value:"SIM1"}],REMO_SELECTALLSIM_NUM_ID2:[{name:"SIM0",value:"SIM0"},{name:"SIM1",value:"SIM1"},{name:"SIM2",value:"SIM2"}],REMO_SELECTALLSIM_NUM_ID3:[{name:"SIM0",value:"SIM0"},{name:"SIM1",value:"SIM1"},{name:"SIM2",value:"SIM2"},{name:"SIM3",value:"SIM3"}],REMO_SELECTSLOTESIM_NUM_ID0:[{name:"SIM1",value:"SIM1"}],REMO_SELECTSLOTESIM_NUM_ID1:[{name:"SIM1",value:"SIM1"},{name:"SIM2",value:"SIM2"}],REMO_SELECTSLOTESIM_NUM_ID2:[{name:"SIM1",value:"SIM1"},{name:"SIM2",value:"SIM2"},{name:"SIM3",value:"SIM3"}],REMO_SELECTSLOTESIM_NUM_ID3:[{name:"SIM1",value:"SIM1"},{name:"SIM2",value:"SIM2"},{name:"SIM3",value:"SIM3"},{name:"SIM4",value:"SIM4"}],REMO_SETSIM_SIM_TYPE:[{name:"Entity",value:"1"},{name:"Virtual",value:"2"}],defaultApnSize:1,maxApnNumber:10,NETWORK_MODES:[{name:"802.11 b/g/n",value:"4"},{name:"802.11 n only",value:"2"}],NETWORK_MODES_BAND:[{name:"802.11 a only",value:"5"},{name:"802.11 n only",value:"2"},{name:"802.11 a/n",value:"4"}],AUTH_MODES:[{name:"NO ENCRYPTION",value:"OPEN"},{name:"WPA2(AES)-PSK",value:"WPA2PSK"},{name:"WPA-PSK/WPA2-PSK",value:"WPAPSKWPA2PSK"}],AUTH_MODES_WEP:[{name:"NO ENCRYPTION",value:"OPEN"},{name:"SHARED",value:"SHARED"},{name:"WPA2(AES)-PSK",value:"WPA2PSK"},{name:"WPA-PSK/WPA2-PSK",value:"WPAPSKWPA2PSK"}],AUTH_MODES_ALL:[{name:"NO ENCRYPTION",value:"OPEN"},{name:"SHARED",value:"SHARED"},{name:"WPA-PSK",value:"WPAPSK"},{name:"WPA2-PSK",value:"WPA2PSK"},{name:"WPA-PSK/WPA2-PSK",value:"WPAPSKWPA2PSK"},{name:"EAP-SIM/AKA",value:"EAP-SIM/AKA"}],LANGUAGES:[{name:"English",value:"en"},{name:"中文",value:"zh-cn"}],AUTO_MODES:[{name:"Automatic",value:"WCDMA_preferred"},{name:"3G Only",value:"Only_WCDMA"},{name:"2G Only",value:"Only_GSM"}],APN_AUTH_MODES:[{name:"NONE",value:"none"},{name:"CHAP",value:"chap"},{name:"PAP",value:"pap"}],SMS_VALIDITY:[{name:"12 hours",value:"twelve_hours"},{name:"A day",value:"one_day"},{name:"A week",value:"one_week"},{name:"The longest period",value:"largest"}],SLEEP_MODES:[{name:"Always on",value:"-1"},{name:"5 minutes",value:"5"},{name:"10 minutes",value:"10"},{name:"20 minutes",value:"20"},{name:"30 minutes",value:"30"},{name:"1 hour",value:"60"},{name:"2 hours",value:"120"}],FORWARD_PROTOCOL_MODES:[{name:"TCP+UDP",value:"TCP&UDP"},{name:"TCP",value:"TCP"},{name:"UDP",value:"UDP"}],MAP_PROTOCOL_MODES:[{name:"TCP+UDP",value:"TCP&UDP"},{name:"TCP",value:"TCP"},{name:"UDP",value:"UDP"}],FILTER_PROTOCOL_MODES:[{name:"NONE",value:"None"},{name:"TCP",value:"TCP"},{name:"UDP",value:"UDP"},{name:"ICMP",value:"ICMP"}],SD_SHARE_ENABLE:[{name:"Enable",value:"1"},{name:"Disable",value:"0"}],SD_FILE_TO_SHARE:[{name:"entire_sd_card",value:"1"},{name:"custom_setting",value:"0"}],SD_ACCESS_TYPE:[{name:"entire_sd_card",value:"1"},{name:"custom_setting",value:"0"}],DLNA_LANGUAGES:[{name:"english",value:"english"},{name:"chinese",value:"chinese"}],DDNSSetMode:[{name:"Enable",value:"1"},{name:"Disable",value:"0"}],ddns_Modeselect:[{name:"manual",value:"manual"},{name:"auto",value:"auto"}],DDNSDDP:[{name:"dyndns.org",value:"dyndns"},{name:"no-ip.com",value:"no-ip"}],SD_BASE_PATH:"/mmc2",dbMsgs:[],listMsgs:[],currentChatObject:null,smsMaxId:0,phonebook:[],smsIsReady:false,countryCodeType:{world:3,mkkc:3,apld:7,etsic:3,fcca:1},countryCode:{world:["AL","DZ","AR","AM","AU","AT","AZ","BH","BY","BE","BA","BR","BN","BG","CL","CN","CR","HR","CY","CZ","DK","EC","EG","SV","EE","FI","FR","F2","GE","DE","GR","HN","HK","HU","IS","IN","ID","IR","IE","IL","IT","JM","JO","KZ","KE","KP","KR","KW","LV","LB","LI","LT","LU","MO","MK","MY","MT","MC","MA","NL","AN","NO","OM","PK","PE","PH","PL","PT","QA","RO","RU","SA","CS","SG","SK","SI","ZA","ES","LK","SE","CH","SY","TH","TT","TN","TR","UA","AE","GB","UY","VN","YE","ZW","BD"],mkkc:["JP"],apld:[],etsic:["BZ","BO","NZ","VE"],fcca:["CA","CO","DO","GT","MX","PA","PR","TW","US","UZ"]},countryCode_5g:{one:{codes:["AL","AI","AW","AT","BY","BM","BA","BW","IO","BG","CV","HR","CY","CZ","DK","EE","FI","FR","GF","PF","TF","GI","DE","GR","GP","GG","HU","IS","IE","IT","KE","LA","LV","LS","LI","LT","LU","MK","MT","IM","MQ","MR","MU","YT","MC","ME","MS","NL","AN","NO","OM","PL","PT","RE","RO","SM","SN","RS","SK","SI","ZA","ES","SE","CH","TC","UG","GB","VG","WF","ZM","AF","JO","MA","EH","EU","DZ","IL","MX","PM","TN","TR","JP"],channels:[36,40,44,48]},two:{codes:["AS","AG","AZ","BR","KH","KY","CO","CR","DM","DO","EC","GH","GD","HK","KZ","KI","FM","MZ","NA","NZ","NI","NE","PW","PE","PH","PR","VC","TH","TT","UY","ZW","AU","BH","BB","CA","CL","CX","EG","SV","GT","HT","IN","MY","NF","PA","PG","SG","US","VN"],channels:[36,40,44,48,149,153,157,161,165]},three:{codes:["CU","IR","KR","SY","LB","MW","MO","QA"],channels:[149,153,157,161]},four:{codes:["BD","BF","CN","HN","JM","PK","PY","KN","AR","TW","NG"],channels:[149,153,157,161,165]},five:{codes:["SA"],channels:[36,40,44,48,149,153,157,161]}},countries:{NONE:"NONE",AL:"SHQIPERI",DZ:"الجزائر",AR:"ARGENTIA",AM:"ՀԱՅԱՍՏԱՆ",AU:"AUSTRALIA",AT:"ÖSTERREICH",AZ:"AZƏRBAYCAN",BD:"বাংলাদেশ",BH:"البحرين",BY:"БЕЛАРУСЬ",BE:"BELGIË",BA:"БОСНА И ХЕРЦЕГОВИНА",BR:"BRASIL",BN:"BRUNEI DARUSSALAM",BG:"БЪЛГАРИЯ",CL:"CHILE",CN:"中国",CR:"COSTA RICA",HR:"HRVATSKA",CY:"ΚΎΠΡΟΣ",CZ:"ČESKÁ REPUBLIKA",DK:"DANMARK",EC:"ECUADOR",EG:"مصر",SV:"EL SALVADOR",EE:"EESTI",FI:"SUOMI",FR:"FRANCE",F2:"FRANCE RESERVES",GE:"საქართველო",DE:"DEUTSCHLAND",GR:"ΕΛΛΆΔΑ",HN:"HONDURAS",HK:"香港",HU:"MAGYARORSZÁG",IS:"ÍSLAND",IN:"INDIA",ID:"INDONESIA",IR:"ایران، جمهوری اسلامی",IE:"ÉIRE",IL:"إسرائيل",IT:"ITALIA",JM:"JAMAICA",JO:"الأردن",KZ:"КАЗАХСТАН",KE:"KENYA",KP:"조선민주주의인민공화국",KR:"한국 ROK",K3:"한국 ROC3",KW:"الكويت",LV:"LATVIJA",LB:"لبنان",LI:"LIECHTENSTEIN",LT:"LIETUVA",LU:"LUXEMBOURG",MO:"澳門",MK:"МАКЕДОНИЈА",MY:"MALAYSIA",MT:"MALTA",MC:"MONACO",MA:"المغرب",NL:"NEDERLAND",AN:"NETHERLANDS ANTILLES",NO:"NORGE",OM:"سلطنة عمان",PK:"PAKISTAN",PE:"PERÚ",PH:"PHILIPPINES",PL:"POLSKA",PT:"PORTUGAL",QA:"قطر",RO:"ROMÂNIA",RU:"Российская Федерация",SA:"السعودية",CS:"Црна Гора",SG:"SINGAPORE",SK:"SLOVENSKÁ REPUBLIKA",SI:"SLOVENIJA",ZA:"SOUTH AFRICA",ES:"ESPAÑA",LK:"SRILANKA",SE:"SVERIGE",CH:"SCHWEIZ",SY:"الجمهورية العربية السورية",TH:"ประเทศไทย",TT:"TRINIDAD AND TOBAGO",TN:"تونس",TR:"TÜRKİYE",UA:"Україна",AE:"الإمارات العربية المتحدة",GB:"UNITED KINGDOM",UY:"URUGUAY",VN:"VIỆT NAM",YE:"اليمن",ZW:"ZIMBABWE",JP:"日本",K2:"한국 ROC2",BZ:"BELIZE",BO:"BOLIVIA",NZ:"NEW ZEALAND",VE:"REPÚBLICA BOLIVARIANA DE VENEZUELA",CA:"CANADA",CO:"COLOMBIA",DO:"REPÚBLICA DOMINICANA",GT:"GUATEMALA",MX:"MEXICO",PA:"PANAMÁ",PR:"PUERTO RICO",TW:"台灣",US:"UNITED STATES",UZ:"O’zbekiston"},countries_5g:{NONE:"NONE",AR:"ARGENTIA",AM:"ՀԱՅԱՍՏԱՆ",AU:"AUSTRILIA",AT:"ÖSTERREICH",AZ:"AZƏRBAYCAN",BH:"البحرين",BY:"БЕЛАРУСЬ",BE:"BELGIË",BA:"БОСНА И ХЕРЦЕГОВИНА",BR:"BRASIL",BN:"BRUNEI DARUSSALAM",BG:"БЪЛГАРИЯ",CL:"CHILE",CN:"中国",CR:"COSTA RICA",HR:"HRVATSKA",CY:"ΚΎΠΡΟΣ",CZ:"ČESKÁ REPUBLIKA",DK:"DANMARK",EC:"ECUADOR",EG:"مصر",SV:"EL SALVADOR",EE:"EESTI",FI:"SUOMI",FR:"FRANCE",F2:"FRANCE RESERVES",GE:"საქართველო",DE:"DEUTSCHLAND",GR:"ΕΛΛΆΔΑ",HK:"香港",HU:"MAGYARORSZÁG",IS:"ÍSLAND",IN:"INDIA",ID:"INDONESIA",IR:"ایران",IE:"ÉIRE",IL:"إسرائيل",IT:"ITALIA",JM:"JAMAICA",JO:"الأردن",KP:"조선민주주의인민공화국",KR:"한국 ROK",K3:"한국 ROC3",LV:"LATVIJA",LI:"LIECHTENSTEIN",LT:"LIETUVA",LU:"LUXEMBOURG",MO:"澳門",MY:"MALAYSIA",MT:"MALTA",MC:"MONACO",NL:"NEDERLAND",AN:"Netherlands Antilles",NO:"NORGE",OM:"سلطنة عمان",PE:"PERÚ",PH:"PHILIPPINES",PL:"POLSKA",PT:"PORTUGAL",SA:"السعودية",CS:"Црна Гора",SG:"SINGAPORE",SK:"SLOVENSKÁ REPUBLIKA",SI:"SLOVENIJA",ZA:"SOUTH AFRICA",ES:"ESPAÑA",LK:"SRILANKA",SE:"SVERIGE",CH:"SCHWEIZ",TT:"TRINIDAD AND TOBAGO",TN:"تونس",TR:"TÜRKİYE",GB:"UNITED KINGDOM",UY:"URUGUAY",JP:"日本",K2:"한국 ROC2",BZ:"BELIZE",BO:"BOLIVIA",NZ:"NEW ZEALAND",VE:"VENEZUELA",CA:"CANADA",CO:"COLOMBIA",DO:"REPÚBLICA DOMINICANA",GT:"GUATEMALA",MX:"MEXICO",PA:"PANAMÁ",PR:"PUERTO RICO",TW:"台灣",US:"UNITED STATES",UZ:"O’zbekiston"},pppoeModes:[{name:"PPPoE",value:"PPPOE"},{name:"Static",value:"STATIC"},{name:"DHCP",value:"DHCP"},{name:"AUTO",value:"AUTO"}],sntpTimeSetMode:[{name:"manual",value:"manual"},{name:"auto",value:"auto"}],timeZone:[{name:"(GMT-12:00) Dateline West",value:"<-12>12_0"},{name:"(GMT-11:00) Midway Islands, Samoa",value:"SST11_0"},{name:"(GMT-10:00) Hawaii",value:"<-10>10_0"},{name:"(GMT-09:00) Alaska",value:"<-09>9_0"},{name:"(GMT-08:00) Pacific time (USA and Canada), Tijuana",value:"PST8PDT,M3.2.0,M11.1.0_0"},{name:"(GMT-07:00) Mountain time (USA and Canada)",value:"<-07>7_0"},{name:"(GMT-07:00) Arizona",value:"<-07>7_1"},{name:"(GMT-07:00) Chihuahua, La Paz, Mazza Tran",value:"MST7MDT,M4.1.0,M10.5.0_2"},{name:"(GMT-06:00) Saskatchewan",value:"<-06>6_0"},{name:"(GMT-06:00) Central time (USA and Canada)",value:"<-06>6_1"},{name:"(GMT-06:00) Central America",value:"<-06>6_2"},{name:"(GMT-06:00) Guadalajara City, Mexico City, Monterey",value:"<-06>6_3"},{name:"(GMT-05:00) Bogota, Lima, Quito",value:"<-05>5_0"},{name:"(GMT-05:00) Eastern time (USA and Canada)",value:"<-05>5_1"},{name:"(GMT-05:00) Indiana (East)",value:"EST5EDT,M3.2.0,M11.1.0_2"},{name:"(GMT-04:00) Atlantic time (Canada)",value:"AST4ADT,M3.2.0,M11.1.0_0"},{name:"(GMT-04:00) Caracas, La Paz",value:"<-04>4_1"},{name:"(GMT-04:00) Santiago",value:"<-04>4<-03>,M8.2.6/24,M5.2.6/24_2"},{name:"(GMT-03:30) Newfoundland",value:"NST3:30NDT,M3.2.0,M11.1.0_0"},{name:"(GMT-03:00) Brasilia",value:"<-03>3_0"},{name:"(GMT-03:00) Buenos Aires, Georgetown",value:"<-03>3_1"},{name:"(GMT-03:00) Greenland",value:"<-03>3_2"},{name:"(GMT-02:00) Mid-Atlantic",value:"<-02>2_0"},{name:"(GMT-01:00) Cape Verde Islands",value:"<-01>1_0"},{name:"(GMT-01:00) Azores",value:"<-01>1<+00>,M3.5.0/0,M10.5.0/1_1"},{name:"(GMT) GMT: Dublin, Edinburgh, London, Lisbon",value:"GMT0IST,M3.5.0/1,M10.5.0_0"},{name:"(GMT) Casablanca, Monrovia",value:"WET0WEST,M3.5.0,M10.5.0/3_1"},{name:"(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna",value:"CET-1CEST,M3.5.0,M10.5.0/3_0"},{name:"(GMT+01:00) Belgrad, Bratislava, Budapest, Ljubljana, Prague",value:"CET-1CEST,M3.5.0,M10.5.0/3_1"},{name:"(GMT+01:00) Brussels, Copenhagen, Madrid, Paris",value:"CET-1CEST,M3.5.0,M10.5.0/3_2"},{name:"(GMT+01:00) Sarajevo, Skopje,Warsaw, Zagreb",value:"CET-1CEST,M3.5.0,M10.5.0/3_3"},{name:"(GMT+01:00) Western Central African",value:"<+01>-1_4"},{name:"(GMT+02:00) Bucharest",value:"EET-2EEST,M3.5.0/3,M10.5.0/4_0"},{name:"(GMT+02:00) Pretoria, Harare",value:"CAT-2_1"},{name:"(GMT+02:00) Helsinki, Kiev, Riga, Sofia, Tallinn, Vilnius",value:"EET-2EEST,M3.5.0/3,M10.5.0/4_2"},{name:"(GMT+02:00) Cairo",value:"EET-2_3"},{name:"(GMT+02:00) Athens, Beirut, Istanbul, Minsk",value:"EET-2EEST,M3.5.0/3,M10.5.0/4_4"},{name:"(GMT+02:00) Jerusalem",value:"IST-2IDT,M3.4.5/02:00:00,M10.5.0/02:00:00_5"},{name:"(GMT+03:00) Baghdad",value:"<+03>-3_0"},{name:"(GMT+03:00) Riyadh, Kuwait",value:"<+03>-3_1"},{name:"(GMT+03:00) Moscow, St Petersburg, Volgograd",value:"<+03>-3_2"},{name:"(GMT+03:00) Nairobi",value:"EAT-3_3"},{name:"(GMT+03:30) Teheran",value:"<+0330>-3:30<+0430>,J80/0,J264/0_0"},{name:"(GMT+04:00) Abu Zabi, Muscat",value:"<+04>-4_0"},{name:"(GMT+04:00) Baku, Tbilisi, Yerevan",value:"<+04>-4_1"},{name:"(GMT+04:30) Kabul",value:"<+0430>-4:30_0"},{name:"(GMT+05:00) Yekaterinburg",value:"<+05>-5_0"},{name:"(GMT+05:00) Islamabad, Karachi, Tashkent",value:"PKT-5_1"},{name:"(GMT+05:30) Madras, Calcutta, Mumbai, New Delhi",value:"<+0530>-5:30_0"},{name:"(GMT+05:45) Kathmandu",value:"<+0545>-5:45_0"},{name:"(GMT+06:00) Ala Mutu, Novosibirsk",value:"<+06>-6_0"},{name:"(GMT+06:00) Dhaka, Astana",value:"<+06>-6_1"},{name:"(GMT+06:00) Sri Haya Ed Denny Pla",value:"<+06>-6_2"},{name:"(GMT+06:30) Yangon",value:"<+0630>-6:30_0"},{name:"(GMT+07:00) Krasnoyarsk",value:"<+07>-7_0"},{name:"(GMT+07:00) Bangkok, Hanoi, Jakarta",value:"<+07>-7_1"},{name:"(GMT+08:00) Beijing, Chongqing, Hongkong Special Administrative Region, Urumqi",value:"CST-8_0"},{name:"(GMT+08:00) Kuala Lumpur, Singapore",value:"<+08>-8_1"},{name:"(GMT+08:00) Perth",value:"AWST-8_2"},{name:"(GMT+08:00) Taipei",value:"CST-8_3"},{name:"(GMT+08:00) Irkutsk, Ulam Batu",value:"<+08>-8_4"},{name:"(GMT+09:00) Osaka, Sapporo, Tokyo",value:"JST-9_0"},{name:"(GMT+09:00) Seoul",value:"KST-9_1"},{name:"(GMT+09:00) Yakutsk",value:"<+09>-9_2"},{name:"(GMT+09:30) Adelaide",value:"ACST-9:30ACDT,M10.1.0,M4.1.0/3_0"},{name:"(GMT+09:30) Darwin",value:"ACST-9:30_1"},{name:"(GMT+10:00) Brisbane",value:"AEST-10_0"},{name:"(GMT+10:00) Vladivostok",value:"<+10>-10_1"},{name:"(GMT+10:00) Guam, Port Moresby",value:"<+10>-10_2"},{name:"(GMT+10:00) Hobart",value:"AEST-10AEDT,M10.1.0,M4.1.0/3_3"},{name:"(GMT+10:00) Canberra, Melbourne, Sydney",value:"AEST-10AEDT,M10.1.0,M4.1.0/3_4"},{name:"(GMT+11:00) Magadan, Solomon islands, New Caledonia",value:"<+11>-11_0"},{name:"(GMT+12:00) Wellington, Oakland",value:"<+12>-12_0"},{name:"(GMT+12:00) Fiji, Kamchatka, Marshall Islands",value:"<+12>-12_1"},{name:"(GMT+13:00) Nukualofa",value:"<+13>-13_0"}],daylightSave:[{name:"Disable",value:"0"},{name:"Enable",value:"1"}],wdsModes:[{name:"Disable",value:"0"},{name:"RootAP Mode",value:"1"},{name:"Bridge Mode",value:"2"},{name:"Repeater Mode",value:"3"}],voipSipDtmfMethod:[{name:"InBand",value:"2"},{name:"RFC2833",value:"3"},{name:"SIPInfo",value:"4"}],sipEncodeMethod:[{name:"G.711 u-Law",value:"0"},{name:"G.711 a-Law",value:"1"},{name:"G.722",value:"2"},{name:"G.729",value:"3"},{name:"G.726-16kps",value:"4"},{name:"G.726-24kps",value:"5"},{name:"G.726-32kps",value:"6"},{name:"G.726-40kps",value:"7"}],FORWARDING_MODES:[{name:"Unconditional forwarding",value:"1"},{name:"When busy",value:"2"},{name:"When no answer",value:"3"},{name:"Cancel all forwarding",value:"0"}],BAUD_RATES:[{name:"9600",value:"9600"},{name:"19200",value:"19200"},{name:"38400",value:"38400"},{name:"57600",value:"57600"},{name:"115200",value:"115200"},{name:"230400",value:"230400"},{name:"460800",value:"460800"},{name:"921600",value:"921600"}]};require(["config/"+a.DEVICE+"/config"],function(b){$.extend(a,b)});return a});