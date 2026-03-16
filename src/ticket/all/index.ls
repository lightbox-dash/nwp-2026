module.exports =
  pkg:
    name: '@grantdash/judge', path: 'option/all.html'
    extend: {name: '@grantdash/judge', path: 'common'}
    dependencies: [
      {name: "ldfile"}
      {name: "csv4xls"}
      {name: "ldcolor"}
      {name: "@loadingio/ldcolorpicker"}
      {name: "@loadingio/ldcolorpicker", type: \css, global: true}
    ]
    i18n:
      en:
        "設定項目": "Options"
        "評分細節": "Detail Result"
        "規則設定": "Rules Setup"
        "簡報順序": "Project Order"
        "選項設定": "Options Setup"
        "結果統計": "Statistics"
        "同分待議": "Tie to Break"
        "未有共識": "No Consensus"
        "入選": "Selected"
        "結果": "Result"
        "總票數": "Ticket"
      "zh-TW":
        "設定項目": "設定項目"
        "評分細節": "評分細節"
        "規則設定": "規則設定"
        "簡報順序": "簡報順序"
        "選項設定": "選項設定"
        "結果統計": "結果統計"
        "同分待議": "同分待議"
        "未有共識": "未有共識"
        "入選": "入選"
        "結果": "結果"
        "總票數": "總票數"
  render: ->
    @statistic!
    @view.render!
    for k,v of (@renders or {}) => v!
    if @active["custom-id"] =>
      p = @submod.project.utils.filtered!filter((p) ~> @active["custom-id"] == @lib.idx prj: p).0
      if p => @pn.get(p).scrollIntoView behavior: \smooth, block: \center
    if @active.order =>
      p = @submod.project.utils.filtered!filter((p) ~> @active.order == @pm.get(p).order).0
      if p => @pn.get(p).scrollIntoView behavior: \smooth, block: \center

  statistic: ->
    @prjs.map (p) ~>
      o = @pm.get p
      o.ticket = @judge.users
        .filter (j) ~> !((((@data.user or {})[j.key] or {}).prj or {})[p.key] or {}).avoid
        .map (j) ~>
          v = ((((@data.user or {})[j.key] or {}).prj or {})[p.key] or {}).v
          if v? => +v else 0
        .reduce(((a,b) -> a + b), 0)
      vm = @vote-method!
      method = {
        quota: {enabled: false, count: 0}
        "threshold-ticket": 0, compare: \gt
      } <<< ((@data.cfg or {}).rule or {})
      method.quota.count = if isNaN(+method.quota.count) => 0 else +method.quota.count

    stats = @prjs.map (prj) ~> {prj, stat: @pm.get(prj)}
    stats.sort (a,b) ~>
      [ta,tb] = [a.stat.ticket, b.stat.ticket]
      if ta > tb => return -1 else if ta < tb => return 1
      # lower system idx = higher order
      [ia, ib] = [@lib.idx(prj: a.prj), @lib.idx(prj: b.prj)]
      if ia > ib => return 1
      else if ia < ib => return -1
      # lower prj key = higher order
      return a.prj.key - b.prj.key
    [rank,ticket] = [1, ((stats.0 or {}).stat or {}).ticket or 0]
    count-til-rank = {}
    for i from 0 til stats.length =>
      # same rank for prjs with same rate ( while they have different orders )
      if stats[i].stat.ticket != ticket => [rank, ticket] = [i + 1, stats[i].stat.ticket]
      stats[i].stat.rank = rank # rank based on rule
      stats[i].stat.order = i # actual order in list
      count-til-rank[rank] = i + 1
    for i from 0 til stats.length =>
      stats[i].stat.count-til-rank = count-til-rank[stats[i].stat.rank]

    sort-method = @tool["all-sort"].get-method!
    group-sort = (a,b) ~>
      gr = ((@data.cfg or {}).group or {})
      if !(gr.enabled and gr.sort) => return 0
      return @group-sorter @get-group(prj:a), @get-group(prj:b)
    if sort-method == \rank =>
      @prjs.sort (a,b) ~>
        if group-sort(a,b) => return that
        @pm.get(a).order - @pm.get(b).order
    else if sort-method == \id =>
      @prjs.sort (a,b) ~>
        if group-sort(a,b) => return that
        [a, b] = [@lib.idx(prj: a), @lib.idx(prj: b)]
        if a > b => 1 else if a < b => -1 else 0
    else if sort-method == \custom-order =>
      orders = ((@data.cfg or {}).orders or {})
      @prjs.sort (a,b) ~>
        if group-sort(a,b) => return that
        [ia, ib] = [@lib.idx(prj: a), @lib.idx(prj: b)]
        oa = (orders[a.key] or {}).value or undefined
        ob = (orders[b.key] or {}).value or undefined
        if !isNaN(+oa) => oa = +oa
        if !isNaN(+ob) => ob = +ob
        ea = (orders[a.key] or {}).disabled
        eb = (orders[b.key] or {}).disabled
        if ea xor eb => return if ea => 1 else -1
        if !(oa? or ob?) =>
          return if ia < ib => -1 else if ia > ib => 1 else 0
        if !(oa?) => return 1
        if !(ob?) => return -1
        return if oa < ob => -1 else if oa > ob => 1 else 0
    stats.map ({prj, stat}) ~>
      ret = @_vote-result stat
      stat.picked = ret
      count = ((@data.cfg or {}).rule or {})["picked-count"] or 0
      if count and stat.rank > count => stat.picked = false

  init: ({root, ctx, manager, pubsub, t}) ->
    {ldcolor} = ctx
    ({core}) <~ servebase.corectx _
    @ldcvmgr = core.ldcvmgr
    @_normalize-threshold = (t) -> if !t? or isNaN(+t) => 0.5 else +((t >? 0 <? 1).toFixed 3)
    @_vote-result = (o) ->
      t = @_normalize-threshold ((@data.cfg or {}).rule or {}).threshold
      threshold-ticket = ((@data.cfg or {}).rule or {})["threshold-ticket"] or 0
      return if o.ticket >= threshold-ticket => true else false

    @result-mark = (o = {}) ->
      prj = o.prj
      if !prj => return {}
      vm = @vote-method!
      stat = @pm.get(prj)
      picked-count = ((@data.cfg or {}).rule or {})["picked-count"]
      is-overflow = !!(picked-count and stat.picked and stat.count-til-rank > picked-count)
      # only vm == \t support
      ret = if vm == \t => {overflow: is-overflow, picked: stat.picked}
      mark = if vm == \t => if ret.picked => (if ret.overflow => '同分待議' else '入選') else ''
      return ret <<< {mark}

    @vote-method = -> return ((@data.cfg or {}).rule or {}).base or \t
    @active = {}
    @type = \all
    pubsub.fire \init, {mod: @, submod, ctx}
    @view = new ldview do
      root: root
      init-render: false
      init: ldcv: @tool.ldcv.view
      handler:
        "wake-lock-state": ({node, views}) ~> node.classList.toggle \on, @wake-lock.query!
        "show-group": ({node}) ~> node.classList.toggle \d-none, !((@data.cfg or {}).group or {}).enabled
        "search-widget": @tool.search.view
        project: @submod.project.view
        "is-admin": ({node}) ~> node.classList.toggle \d-none, !@is-admin!
        "ldcv-rule": @submod.rule.view
        "ldcv-monitor": @submod.monitor.view
        "summary": ({node}) ~>
          hide = !(@vote-method! in (node.getAttribute(\data-name) or '').split(\,))
          node.classList.toggle \d-none, hide
        judge:
          list: ~> @judge.users
          key: -> it.key
          view: text: "name": ({node, ctx, ctxs}) ~>
            if @judge.form.config.anonymous => "評審" + @judge.users.indexOf(ctx)
            else ctx.nickname or ctx.displayname
        result: ({node, ctx}) ~>
          list = @submod.project.utils.filtered!
          passed = list.filter((p) ~> @pm.get(p).picked).length
          total = list.length
          type = node.getAttribute \data-name
          node.innerText = (if type == \1 => passed else if type == \2 => total else (total - passed))
        "group-summary":
          list: ~> @brd.detail.{}group.[]list
          key: -> it.slug
          view:
            text: name: ({ctx}) -> ctx.info.name
            handler:
              result: ({node, ctx}) ~>
                list = @submod.project.utils.filtered!
                list = list.filter (p) ~> @get-group(prj: p).slug == ctx.slug
                passed = list.filter((p) ~> @pm.get(p).picked).length
                total = list.length
                type = node.getAttribute \data-name
                node.innerText = (if type == \1 => passed else if type == \2 => total else (total - passed))
        "all-sort": @tool["all-sort"].view
      action:
        click:
          "toggle-wake-lock": ({node, views, evt}) ~>
            evt.stopPropagation!
            @wake-lock.toggle!then ~> views.0.render \wake-lock-state
          publish: ~>
            badges = ((@brd.detail.prj or {}).config or {}).badges or []
            core.ldcvmgr.get(
              {name: '@grantdash/judge', path: 'common/publishing.html'}
              {badge: \shortlisted, badges}
            )
              .then (badge-name) ~>
                if !badge-name => return
                core.loader.on!
                vm = @vote-method!
                list = @submod.project.utils.filtered!
                  .map (p) ~>
                    stat = @pm.get(p)
                    # NOTE this is for vm == \t
                    {key: +p.key, badge: stat.picked}
                json = {prjs: list, badge: badge-name}
                debounce 1000
                  .then ~> @publish json
                  .finally -> core.loader.off!
                  .then ~>
                    core.ldcvmgr.get(
                      {name: '@grantdash/judge', path: 'common/published.html'}
                    )
          "toggle-order": ~> @tool.order.view!
          "toggle-i18n": ~> @tool.i18n.view!
          "toggle-group": ~> @tool.group.view!
          "toggle-rule": ~> @ldcv.rule.toggle!
          "toggle-monitor": ~> @ldcv.monitor.toggle!
          "toggle-detail": ~>
            payload = {
              custom-fields: (o = {}) ~>
                if !o.prj =>
                  return [
                  * value: t("總票數"), key: "_總票數"
                  * value: t("結果"), key: "_結果"
                  ] #++ @options.list!map (d) -> {value: t("_local:#{d.name}"), key: d.key}
                p = @pm.get(o.prj)
                result = @result-mark {prj: o.prj}
                return [
                * value: p.ticket, key: "_總票數"
                * value: result.mark, key: "_結果"
                ] #++ @options.list!map (d) -> {value: (p.count or {})[d.key] or 0, key: d.key}
              rank: ({prj}) ~> @pm.get(prj).rank
              score: ({judge, prj}) ~>
                return (@data.user{}[judge.key].{}prj[prj.key] or {}).v or 0
            }
            # original bid
            #bid = {name: '@grantdash/judge', path: 'common/detail.html'},
            # customized bid
            bid = {ns: \template/nwp-2026, name: \block, path: 'ticket/detail.html'}
            _ = ({custom-fields, score, rank}) ~>
              @ldcvmgr.get(
                bid,
                ({} <<< @{brd,grp,prjs,judge,data,lib} <<< {score, custom-fields, rank})
              )
            _(payload)
            @ldcvmgr.getcover bid
              .then (cover) ~>
                if @{}renders["detail"] => return
                @renders["detail"] = ~> cover.fire \data, ({} <<< @{brd,grp,prjs,judge,data,lib} <<< payload)
          "download-csv": ~> @submod.download.obj.run.apply @, [{ctx,t}]
