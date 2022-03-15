CREATE TABLE "public"."customer"(id        integer NOT NULL encode az64,
                                 firstname character varying(256) encode lzo,
                                 lastname  character varying(256) encode lzo,
                                 gender    character varying(256) encode lzo,
                                 CONSTRAINT customer_pkey PRIMARY KEY(id)) distkey(id);