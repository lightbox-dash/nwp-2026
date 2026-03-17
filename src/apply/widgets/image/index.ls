module.exports =
  pkg:
    name: "@makeform/image", extend: {ns: "template/nwp-2026", name: "block", path: 'apply/widgets/upload/index.html'}
    dependencies: [
      {url: "https://cdn.jsdelivr.net/npm/imgtype@0.0.1/index.min.js"}
    ]

  init: ({ctx, root, parent}) ->
    {imgtype} = ctx
    lc = {}
    is-supported = (file) ->
      (res, rej) <- new Promise _
      try
        fr = new FileReader!
        fr.onload = ->
          ({ext, mime}) <- imgtype(new Uint8Array fr.result).then _
          res if !ext => {supported: false} else {supported: true}
        fr.readAsArrayBuffer(file)
      catch e
        rej e
    view = new ldview do
      root: root
      ctx: {}
      init:
        dialog: ({node}) ->
          lc.ldcv = new ldcover root: node
          lc.viewer  = ld$.find(node, '[ld=container]',0)
          lc.open  = ld$.find(node, '[ld=open]',0)
      handler:
        image:
          list: ({ctx}) ->
            file = ctx.file
            lc.filelist = file
            if Array.isArray(file) => file else if file => [file] else []
          view:
            action: click:
              "@": ({ctx}) ->
                lc.current = ctx.url
                lc.viewer.innerHTML = ""
                img = new Image!
                img.src = ctx.url
                lc.viewer.appendChild img
                lc.open.setAttribute \href, ctx.url
                lc.ldcv.toggle!

            handler:
              image: ({node,ctx}) -> node.setAttribute \src, ctx.url
      action: click:
        "next-img": ~>
          idx = lc.filelist.findIndex (f) -> f.url is lc.current
          nextIdx = (idx + 1)%lc.filelist.length
          lc.current = lc.filelist[nextIdx].url
          lc.viewer.innerHTML = ""
          img = new Image!
          img.src = lc.current
          lc.viewer.appendChild img
          lc.open.setAttribute \href, lc.current
        "prev-img": ~>
          idx = lc.filelist.findIndex (f) -> f.url is lc.current
          nextIdx = (idx - 1 + lc.filelist.length)%lc.filelist.length
          lc.current = lc.filelist[nextIdx].url
          lc.viewer.innerHTML = ""
          img = new Image!
          img.src = lc.current
          lc.viewer.appendChild img
          lc.open.setAttribute \href, lc.current


    detail = (v) ->
      ps = v.map (f) ->
        (res, rej) <- new Promise _
        img = new Image!
        img.onload = ->
          {width, height} = img{width, height}
          ret = {width, height} <<< (
            if width > height => {long: width, short: height}
            else {long: height, short: width}
          )
          ret.pixels = ret.width * ret.height
          URL.revokeObjectURL img.src
          res(f <<< ret)
        img.src = URL.createObjectURL(f.blob)
      Promise.all ps

    parent.ext {view, is-supported, detail}
