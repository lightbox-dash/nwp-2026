fc = {}

fc["參賽資格"] =
  type: \@makeform/checklist
  meta:
    is-required: true
    config:
      items: [
        "有中華民國國籍，或持中華民國有效居留證，且在台居住超過 183 天之外國籍人士，皆可報名。"
        "未曾於「國內外之公、私立美術館、商業畫廊、藝術博覽會」舉辦個展。"
        "參加「國內外之公、私立美術館、商業畫廊、藝術博覽會」之聯展，不超過 5 次。（意即 0 至 5 次，皆可參加。）"
      ]

fc["作品規範"] =
  type: "@makeform/agreement"
  meta:
    is-required: true
    config:
      display: \inline
      value: "我已詳閱，且作品符合上述規範"

fc["參賽需知"] =
  type: "@makeform/agreement"
  meta:
    is-required: true
    config:
      display: \inline
      value: "我已詳閱，並同意遵守上述內容"

fc["真實姓名"] =
  meta: is-required: true

fc["別名"] =
  meta:
    is-required: false
    config: note: ["填寫別名之參加者，若獲獎將以別名進行公告，不揭露真實姓名。"]

fc["團體名稱"] =
  meta:
    is-required: false
    config: note: ["團體報名者必填，個人報名者請留白。"]

fc["性別"] =
  type: \@makeform/radio
  meta:
    is-required: true
    config: values: <[女性 男性 自定義]>

fc["生日"] =
  type: \@makeform/date
  meta: is-required: true

fc["國籍"] =
  type: \@makeform/radio
  meta:
    is-required: true
    config: 
      values: <[具中華民國國籍 外國籍，具中華民國有效居留證]>

fc["居住地"] =
  type: \@makeform/choice
  meta:
    is-required: true
    config:
      values: <[
        屏東縣 高雄市 台南市 嘉義縣／市 雲林縣 彰化縣
        南投縣 台中市 苗栗縣 新竹縣／市 桃園市 台北市
        新北市 基隆市 宜蘭縣 花蓮縣 台東縣 澎湖縣 連江縣 金門縣
      ]> 
      other: enabled: true, prompt: "居住於國外，請自行填寫"

fc["電子信箱"] =
  meta:
    is-required: true
    term: [ {opset: \string, enabled: true, op: \email, msg: "格式不符", config: {}} ]

fc["聯絡電話"] =
  meta:
    is-required: true
    term: [
      {
        opset: \string, enabled: true, op: \regex, msg: "格式不符",
        config: rule: "^\\d{4}-\\d{6}$|^\\d{2,3}-\\d{7,8}$"
      }
    ]
    config: note: ["填寫格式：0912-345678／02-23456789"]

fc["作品名稱-中文"] =
  meta:
    title: "作品名稱（中文）"
    is-required: true

fc["作品名稱-英文"] =
  meta:
    title: "作品名稱（英文）"
    is-required: true

fc["作品簡介-中文"] =
  type: \@makeform/textarea
  meta:
    title: "作品簡介（中文）"
    is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config: note: ["500 字以內"]

fc["作品簡介-英文"] =
  type: \@makeform/textarea
  meta:
    title: "作品簡介（英文）"
    is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config: note: ["500 字以內"]

fc["創作媒材揭露：影像內容是否源自生成式 AI 工具？"] =
  type: \@makeform/radio
  meta:
    is-required: true
    config:
      values: <[是 否]>
      note: ["不影響參加資格，惟請照實填寫。"]

fc["作品上傳"] =
  type: {ns: \template/nwp-2026, name: \block, path: \apply/widgets/image/index.html}
  meta:
    is-required: true
    term: [
    * opset: \file, enabled: true, op: \count-range, msg: '請上傳 15 - 25 張作品圖檔，將視為一組作品'
      config: min: 15, max: 25
    * opset: \image, enabled: true, op: \long-side, msg: '長邊須為 3,000 像素'
      config: min: 2999, max: 3001
    * opset: \file, enabled: true, op: \extension, msg: '影像須為 jpg 檔'
      config: str: "jpg,jpeg"
    * opset: \file, enabled: true, op: \size-limit, msg: '單張影像須小於 3MB'
      config: val: 3145728
    ]
    config:
      multiple: true
      note: [
        "請上傳 15 - 25 張作品圖檔，將視為一組作品。"
        "影像須為 jpg 檔，長邊須等於 3,000 像素，另一邊須小於或等於 3,000 像素。"
        "單張影像須小於 3MB。"
      ]

fc["上傳作品之展呈示意圖"] =
  type: {ns: \template/nwp-2026, name: \block, path: \apply/widgets/image/index.html}
  meta:
    is-required: false
    term: [
    * opset: \file, enabled: true, op: \count-range, msg: '請上傳至多3張呈現作品的展示規劃'
      config: min: 0, max: 3
    * opset: \image, enabled: true, op: \long-side, msg: '長邊須為 3,000 像素'
      config: min: 2999, max: 3001
    * opset: \file, enabled: true, op: \extension, msg: '影像須為 jpg 檔'
      config: str: "jpg,jpeg"
    * opset: \file, enabled: true, op: \size-limit, msg: '單張影像須小於 3MB'
      config: val: 3145728
    ]
    config:
      multiple: true
      note: [
        "非必填。"
        "請以示意圖（至多3張）呈現作品的展示規劃。"
        "展示牆面尺寸：寬 3 公尺、高 2.5 公尺。"
        "影像須為 jpg 檔，長邊須等於 3,000 像素，另一邊須小於或等於 3,000 像素。"
        "單張影像須小於 3MB。"
      ]

fc["自我介紹"] =
  type: \@makeform/textarea
  meta:
    title: "自我介紹（中文）"
    is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config: note: ["500 字以內"]


fc["參展經歷"] =
  type: \@makeform/textarea
  meta:
    title: "參展經歷（中文）"
    is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config:
      note: [
        "500 字以內"
        "請條列所有參展經歷。若無，請填寫無。"
      ]

fc["是否具學生身分？"] =
  type: \@makeform/radio
  meta:
    title: "您的身分別？"
    is-required: true
    plugin: [
    * type: \dependency
      config:
        values: ["學生、身心礙障者"]
        is-required: true
        visible: true
        disabled: false
        targets: <[上傳證件]>
    ]
    config:
      values: <[一般（個人、團體） 學生、身心礙障者]>
      note: [
        "僅影響報名費用。",
        "若以團體名義參加，無論團體的人數或身分，報名費皆為 1,200 元。",
        "學生身分定義：就讀中華民國公、私立國中小、高中、高職之在學生，以及大專院校在學學生包含大專、專科、軍警學校及宗教院校。但不包含私人補習班、社區大學、空中大學、空中學院及大專院校附設之進修補習班。學制包含二專、五專、二技、四技、大學、碩士及博士。部別包含日間部、夜間部、進修部（須為上述學制）及在職專班（須為上述學制）。"
      ]

fc["上傳證件"] =
  type: \@makeform/upload
  meta:
    visible: false
    is-required: false
    disabled: true
    title: "上傳學生證、身心障礙證明之正面照"
    note: ["具學生證、身心障礙證明者，請上傳證件之正面照片。"]

fc["報名費-一般"] =
  type: {name: \@grantdash/dart, path: \block/widget/payment}
  meta:
    title: "個人、團體參加者"
    is-required: true
    config:
      target: "報名費-一般"
      desc: "攝影創作獎報名費"
      code: "攝影創作獎報名費-個人、團體參加者"
      amount: "1200"
      unit: \新台幣

fc["報名費-學生"] =
  type: {name: \@grantdash/dart, path: \block/widget/payment}
  meta:
    title: "學生、身心障礙者"
    is-required: false
    disabled: true
    config:
      target: "報名費-學生"
      desc: "攝影創作獎報名費"
      code: "攝影創作獎報名費-學生、身心障礙者"
      amount: "600"
      unit: \新台幣

fc["繳費方式"] =
  type: 
    name: \@makeform/radio
    version: "1.3.2"
    path: "index.html"
  meta:
    is-required: true
    config: values: [
      {value: "線上刷卡", label: "線上刷卡／超商條碼"}
      {value: "其他付款方式", label: "其他付款方式"}
    ]
    plugin: [
    * type: \dependency
      config:
        values: ["其他付款方式"]
        visible: true
        targets: <[其他付款方式]>
    ]

fc["票號或訂單編號"] =
  type: \@makeform/input
  meta:
    is-required: false
    disabled: true
    term: [{
      opset: \string, enabled: true, op: \regex, msg: "格式不符",
      config: rule: "^[a-zA-Z0-9]{13}$"
    }]
    config:
      note: [
        '應為 13 碼英數組合'
      ]
