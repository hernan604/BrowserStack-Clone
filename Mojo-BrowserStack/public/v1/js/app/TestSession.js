Class("TestSession", {
    //LIST THE USER TEST SESSIONS
    has : {
        app             : { is : 'rw' },
        sessions        : { is : 'rw', init : ( function () { return [] } )()},
        tpl             : { is : 'rw', init : ( function () {
            return "\
                <li class='{{status}}' data-id='{{id}}'>\
                    <span class='icon-status'></span>\
                    <div class='title'>\
                        {{name}}\
                        <span class='icon-device'></span>\
                    </div>\
                    <span class='time-start'>{{created}}</span>\
                    <span class='duration'>{{created}}</span>\
                </li>\
            ";
            
        } )() },
        target : { is : 'rw' },
        current_session : { is : 'rw' },
    },
    methods : {
        get_sessions : function () {
            var _this = this;
            $.ajax({
                url     : '/v1/user/sessions',
                cache   : false,
                async   : true,
                success : function ( data ) {
                    console.log( 'user test sessions', data );
                    _this.setSessions( data.sessions );
                    _this.render();
                },
                contentType : 'application/json',
                dataType    : 'json',
                type        : 'GET'
            }); 
        },
        init : function () {
            var _this = this;
            _this.app.named_instances.TestSession = _this;
            $(document).ready(function () {
                _this.setTarget( $( '.test-sessions' ) );
                _this.get_sessions();
                setInterval( function () {
                    _this.get_sessions();
                }, 3000 )
            }); 
        },
        render : function () {
            var self = this;
            var reversed = self.sessions.reverse();
            for ( var i=0,item; item = reversed[i]; i++ ) {
                if ( $('.test-sessions [data-id='+item.id+']').length ) { 
                    continue;
                }
                var markup = $( Mustache.render( self.tpl, item ) );
                markup
                    .click( function ( ev ) {
                        var target = $( ev.currentTarget );
                        self.open( target.data('id') );
                    } )
                    .prependTo( self.target )
                    ;
            }
        },
        show_vm_screenshot : function ( ) {
            var self = this;
            var target = $('.machine-screenshot');
            var img = new Image();
            img.src = '/v1/live-screenshot/'+self.current_session.id+".png?"+Math.random();
            img.onload = function () {
                target.html(img);
            }
        },
        open : function ( test_id ) {
            var self = this;
            //open a test and its details
            $.ajax( {
                url     : '/v1/test/'+test_id,
                cache   : false,
                async   : true,
                success : function ( data ) {
//                  console.log( "current session id", data );
                    self.setCurrent_session( data.session );
                    self.render_test_detail( data );
                    self.show_vm_screenshot( );

                    if ( self.current_session.status == 'initialized' ) {
                        setTimeout( function () { self.open( self.current_session.id ) } , 2000)
                    }
                },
                contentType : 'application/json',
                dataType    : 'json',
                type        : 'GET'
            } );
        },
        render_test_detail : function ( data ) {
            console.log('render test detail', data);
            var target = $('.col-right');
            target.html('');
            var tpl_headers = "\
                <table class='test-summary'>\
                    <tr>\
                        <td>Started</td>\
                        <td>{{created}}</td>\
                    </tr>\
                    <tr>\
                        <td>Duration</td>\
                        <td>{{duration}}</td>\
                    </tr>\
                    <tr>\
                        <td>Status</td>\
                        <td>{{status}}</td>\
                    </tr>\
                    <tr>\
                        <td>Device</td>\
                        <td>{{device}}</td>\
                    </tr>\
                    <tr>\
                        <td>Browser</td>\
                        <td>{{browser}}</td>\
                    </tr>\
                    <tr>\
                        <td>Version</td>\
                        <td>{{version}}</td>\
                    </tr>\
                    <tr>\
                        <td>Platform</td>\
                        <td>{{platform}}</td>\
                    </tr>\
                </table>\
            ";
            var markup_header = $( Mustache.render( tpl_headers, data.session ) )
                .appendTo( target );

            var steps = $( '<table/>' )
                .addClass('test-steps')
                .append('<tr><td>Start</td><td>Duration</td><td>Action</td></tr>')
                ;

            var tpl_step = "\
                <tr>\
                    <td class='created'>{{created}}</td>\
                    <td class='elapsed'>{{elapsed}}</td>\
                    <td class='action'>{{action}}</td>\
                </tr>\
            ";
            for (var i=0,item; item=data.result[i]; i++) {
                $( Mustache.render( tpl_step, item ) )
                    .appendTo( steps )
                    ;
            }

            steps.appendTo( target );

        }
    },
//  after : {
//  }
})
