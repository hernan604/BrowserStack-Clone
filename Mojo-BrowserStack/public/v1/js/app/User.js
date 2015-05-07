Class("User", {
    has : {
        app             : { is : 'rw' },
        target          : { is : 'rw' },
        profile         : { is : 'rw' },
    },
    methods : {
        init : function () {
            var self = this;
            $(document).ready(function () {
                self.setTarget( $( '.accesskeys>.show' ) );
                self.target.click( function ( ev ) {
                    self.show_credentials();
                } );
            }); 
        },
        show_credentials : function () {
            var self = this;
            $.ajax({
                url     : '/v1/user/profile',
                cache   : false,
                async   : true,
                success : function ( profile ) {
                    self.setProfile( profile.result );
                    self.show();
                },
                contentType : 'application/json',
                dataType    : 'json',
                type        : 'GET'
            }); 
        },
        show : function () {
            var self = this;
            var tpl = "\
                <table>\
                    <tr>\
                        <td>Firstname</td>\
                        <td>{{firstname}}</td>\
                    </tr>\
                    <tr>\
                        <td>Lastname</td>\
                        <td>{{lastname}}</td>\
                    </tr>\
                    <tr>\
                        <td>Email</td>\
                        <td>{{email}}</td>\
                    </tr>\
                    <tr>\
                        <td>Created</td>\
                        <td>{{created}}</td>\
                    </tr>\
                    <tr>\
                        <td>username</td>\
                        <td>{{username}}</td>\
                    </tr>\
                    <tr>\
                        <td>Password</td>\
                        <td>{{password}}</td>\
                    </tr>\
                </table>\
            ";
            var content = $('.accesskeys .content').html('');
            var markup = $( Mustache.render( tpl, self.profile ) )
                .appendTo( content );
            markup.click( function ( ev ) { $( ev.currentTarget ).remove() } )
        },
    },
//  after : {
//  }
})
