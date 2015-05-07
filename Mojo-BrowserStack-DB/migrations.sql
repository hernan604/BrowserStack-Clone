-- 1 up

CREATE TABLE "User" (
    id          serial NOT NULL,
    email       text,
    username    text,
    password    text,
    firstname   text,
    lastname    text,
    created     timestamp without time zone default (now() at time zone 'utc'),
    PRIMARY KEY (id)
);

CREATE TABLE "SeleniumSession" (
    id          uuid NOT NULL,
    created     timestamp without time zone default (now() at time zone 'utc'),
    status      text default 'initialized',
    user_id     integer     NOT NULL    REFERENCES "User" (id),
    browser     text,
    version     text,
    platform    text,
    host        text,
    port        text,
    name        text,
    tags        text,
    vm_name     text, -- virtual machine name 
    vm_host_ip  text, -- virtual machine host ip
    PRIMARY KEY (id)
);

CREATE TABLE "SeleniumLog" (
    id          serial NOT NULL,
    selenium_session_id uuid NOT NULL REFERENCES "SeleniumSession" (id),
    created     timestamp without time zone default (now() at time zone 'utc'),
    action      text,
    elapsed     text,
    PRIMARY KEY (id)
);

INSERT  INTO "User" (email, username, password, firstname, lastname)
        VALUES ('teste@example.com','teste','teste123','Testes','da Vida');


