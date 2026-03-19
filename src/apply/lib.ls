window.lib = ({def, i18n}) ->
  idx: ({prj}) ->
    idx = (prj.system or {}).idx
    if !(idx?) => \???
    else if isNaN(idx) => idx
    else "2026-" + "#idx".padStart(3, "0")
  info: ({prj}) ->
    _ = (v) -> (if v => v.v else v) or 'n/a'
    form = ((prj.detail or {}).custom or {})[def.config.alias or def.slug] or {}
    lng = i18n.getLanguage!
    data =
      name: _(form["作品名稱-中文"])+"／"+_(form["作品名稱-英文"])
      description: ""
      team:
        name: _(form["真實姓名"])
        taxid: ""
        pic: ""
      contact:
        email: _(form["電子信箱"])
        name: _(form["真實姓名"])
        mobile: _(form["聯絡電話"])
        title: ""
        addr: ""
      budget:
        total: 0
        "expected-subsidy": 0
