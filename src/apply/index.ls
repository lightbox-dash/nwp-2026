module.exports =
  pkg:
    name: "@grantdash/prj.tdb.boilerplate"
    extend: name: "@grantdash/prj.tdb"
    dependencies: [ {name: "ldview"} ]
    i18n:
      en:
        title:
          year: ""
          name: "New Wave 攝影創作獎"
          date: "Application Period: March 20, 2026, to April 30, 2026 (until 11:59, UTC+8)."
        "必填項目提示": [
          "Fields marked with"
          "are required"
        ]
        "error": "please fix error"
      "zh-TW":
        title:
          year: ""
          name: "New Wave 攝影創作獎"
          date: "徵件時間：2026 年 3 月 20 日－4 月 30 日（上午 11 點 59 分止，UTC+8）"
        "必填項目提示": [
          "標示"
          "為必填項目。"
        ]
        "error": "請修正錯誤"

  init: ({root, ctx, manager, pubsub, i18n, t}) ->
    pubsub.fire \init, mod({root, ctx, t, pubsub, manager, bi: @_instance})

mod = ({root, ctx, t, pubsub, manager, bi}) ->
  mgr = manager
  render: ->
    # `render` is called when host decides to re-render.
    # when anything that may need a re-render, it should be called here.
    @optin!
    @_ldview.render!
  info:
    # subset: field identifier defined in project config,
    #   for prj data to store in prj data object.
    # TODO this should be retrieved automatically from prjdef
    #   and used only if we need a different field.
    subset: "open"
    # your field definition list for prj.tdb to initialize
    fields: fc
  init: (base) ->
    @formmgr = base.formmgr
    @{}_visibility
    @ldcv = {}
    # for any additional i18n data,
    # store it in `i18n-ext = {en: ..., zh: ...}` object
    if i18n-ext? =>
      for lng, res of {en: i18n-ext.en, "zh-TW": i18n-ext.zh} =>
        block.i18n.add-resource-bundle lng, "", res, true, true
    bi.transform \i18n
    block.i18n.module.on \languageChanged, ->
    _debounce-render = debounce 350, ~> view.render!
    ret = null
    getInstructions = ->>
      if(!ret) =>
        res = await fetch('https://www.lightboxlib.org/jsonapi/node/annual_plan_library/4d6f62ea-3521-476a-877d-6a6b5abb8188')
        ret := await res.json!
      ret?.data?.attributes?.field_what?.value
    @_ldview = view = new ldview do
      init-render: false
      root: root
      # for any customization of your view, add it here.
      init: dropdown: ({node}) -> new BSN.Dropdown node
      handler:
        visibility: ({node}) ~>
          name = node.getAttribute \data-name
          node.classList.toggle \d-none, (@_visibility[name]? and !@_visibility[name])
        "lb-instructions": ({node}) ~>>
          node.innerHTML = await getInstructions!
          
    @formmgr.on \change, debounce 350, ~> @optin!
    @optin!

  optin: ->
    # optin is for post action after user made some changes.
    #   e.g., enable certain fields when user choose some values.
    # we don't expliticly limit how `optin` should be implemented, 
    #   however `plugin-run` below is an example reading the `plugin` array in field definition
    #   and process based on its `type`. Only `dependency` type is supported in below example.
    # a sample complete field definition with plugin is as below:
    /*
    "project-type":
      type: "@makeform/radio"
      meta:
        title: "計劃類型"
        is-required: true
        config: values: <[personal cooperation]>
        plugin: [
          * type: \dependency
            config:
              values: <[cooperation]>
              is-required: true
              visible: true
              targets: <[incorporate-document]>
        ]
    */

    # targets is required/visible(based on `is-required` and `visible` field) only if name = val
    dependency = ({source, values, targets, is-required, disabled, visible}) ~>
      itf = fc[source].itf
      content = itf.content!
      content = if Array.isArray(content) => content else [content]
      active = !!content.filter((c) -> if Array.isArray(values) => (c in values) else (c == values)).length
      for tgt in targets =>
        if visible? => @_visibility[tgt] = if visible => active else !active
        if !(fc[tgt] and (o = fc[tgt].itf)) => continue
        c = o.serialize!
        if disabled? => c.disabled = if disabled => active else !active
        if is-required? => c.is-required = if is-required => active else !active
        o.deserialize c

    plugin-run = (k, v, p = {}) ->
      if p.type == \dependency =>
        cfg = p.{}config{values, is-required, visible, disabled}
        cfg <<< if p.config.source => {source: p.config.source, targets: [k]}
        else {source: k, targets: p.config.targets}
        dependency cfg
    for k,v of fc =>
      ((v.meta or {}).plugin or []).map -> plugin-run(k, v, it)

    # 透過「繳費方式」與「是否具學生身分？」來決定「票號或訂單編號」、「報名費-一般」、「報名費-學生」的狀態
    method = fc["繳費方式"].itf.content!
    role = fc["是否具學生身分？"].itf.content!
    [
      <[票號或訂單編號 其他付款方式]>
      <[報名費-一般 線上刷卡 否]>
      <[報名費-學生 線上刷卡 是]>
    ].map (list) ~>
      widget = fc[list.0].itf
      cfg = widget.serialize!
      active = if method == list.1 =>
        # 元件需要的繳費方式與目前的值相同. 接著要看身份.
        # 若身份有定義, 則必須與身份相符; 若無定義, 代表不需看身份
        if !list.2? or list.2 == role => true else false
      else false # 元件需要的繳費方式與目前的值不同, 自然不需要填寫
      cfg <<< disabled: !active, is-required: active
      @_visibility[list.0] = active
      widget.deserialize cfg


  brief: ->
    # this fields are used for basic prj information used by backend.
    # e.g., `name` and `description` are stored directly in db column for quick access of prj basic info.
    name: @formmgr.content("作品名稱")
    description: @formmgr.content("作品簡介-中文")
    thumb: ((@formmgr.content("作品上傳") or []).0 or {}).url
