\begin{section}{}
~~~<div id="mdpad"></div></div>
~~~
\end{section}


~~~

<script src="libs/mdpad/mdpad.js"></script>
<script src="libs/mdpad/mdpad-mithril.js"></script>
<script src="libs/wasm-ffi.browser.js"></script>

~~~
{{ rawoutput j5 }}
~~~

<script src="https://cdnjs.cloudflare.com/ajax/libs/mithril/2.0.4/mithril.min.js"></script>
<script src="https://cdn.plot.ly/plotly-basic-1.54.1.min.js"></script>


<script>
const library = new ffi.Wrapper({
  julia_solv: ['number', [GPUTsit5Integrator, ffi.rust.vector('f64'), ffi.rust.vector('f64'),
                                              ffi.rust.vector('f64'), ffi.rust.vector('f64')]],
}, {debug: false});

library.imports(wrap => ({
  env: {
    memory: new WebAssembly.Memory({ initial: 16 }),
  },
}));

var t = new ffi.rust.vector('f64', new Float64Array(10000))
var u1 = new ffi.rust.vector('f64', new Float64Array(10000))
var u2 = new ffi.rust.vector('f64', new Float64Array(10000))
var u3 = new ffi.rust.vector('f64', new Float64Array(10000))


async function mdpad_init() {
    await library.fetch('libs/julia_solv.wasm')
    var layout =
      m(".row",
        m(".col-md-3",
          m("br"),
          m("br"),
          m("form.form",
            minput({ title:"a", mdpad:"p1", step:0.1, value:0.1 }),
            minput({ title:"b", mdpad:"p2", step:0.1, value:0.1 }),
            minput({ title:"c", mdpad:"p3", step:0.2, value:14.0 }),
           )),
        m(".col-md-1"),
        m(".col-md-8",
          m("#results"),
          m("#plot1", {style:"max-width:500px"})),
      m(".row",
        m(".col-md-1"),
        m(".col-md-8",
          m("#plot2"))))
    await m.render(document.querySelector("#mdpad"), layout);
}

function mdpad_update() {
    var integ = new_integ();
    integ.p.data = [mdpad.p1, mdpad.p2, mdpad.p3];
    library.julia_solv(integ, t, u1, u2, u3);
    integ.free();
    tdata = [{x: t.values, y: u1.values, type: "line", name: "x"}, 
            {x: t.values, y: u2.values, type: "line", name: "y"}, 
            {x: t.values, y: u3.values, type: "line", name: "z"}] 
    tplot = mplotly(tdata, { width: 900, height: 300, margin: { t: 20, b: 20 }}, {responsive: true})
    m.render(document.querySelector("#plot2"), tplot)
    xydata = [{x: u1.values, y: u2.values, type: "line", name: "x"}] 
    xyplot = mplotly(xydata, { width: 400, height: 400, margin: { t: 20, b: 20, l: 20, r: 20 }}, {responsive: true})
    m.render(document.querySelector("#plot1"), xyplot)
}
</script>

~~~
