Class('MyApp', {
    does : [],
    has : {
        deps : {
            is      : "rw",
        },
        lib_loader  : { is  : "rw" },
        ws          : { is  : "rw" },
        named_instances   : {
            is      : "rw", 
            init    : (function(){ return {};})() 
        },
        instances   : {
            is      : "rw", 
            init    : (function(){ return [];})() 
        },
        my_nick : { is : 'rw' },
    },
    methods : {
        load_libs : function () {
            var _this = this;
            this.when_done = _this.carregou_libs;
        },
        init : function () {
            var _this = this;
            for (var i=0, myclass; myclass = this.deps[i]; i++) {
                console.log( myclass );
                var myinstance = new myclass({
                    app : _this
                });
                ( myinstance.init )
                    ? myinstance.init()
                    : undefined
                    ;
            }
        }
    },
    after : {
        initialize: function () {
            console.log('MyApp inicializada');
            this.init();
        },
    },
    before : {
        initialize : function () {
            jloader.load('/v1/js/jquery.js', { eval : false });
            jloader.load('/v1/js/bootstrap.min.js', { eval : false });
            jloader.load('/v1/js/mustache.js', { eval : false });
//          jloader.load('./js/handlebars-v3.0.0.js', { eval : false })
        }
    }
})
