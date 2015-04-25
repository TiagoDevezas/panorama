--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: articles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE articles (
    id integer NOT NULL,
    title character varying(255),
    url text,
    pub_date timestamp without time zone,
    feed_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    twitter_shares integer,
    facebook_shares integer,
    summary text
);


--
-- Name: articles_cats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE articles_cats (
    article_id integer,
    cat_id integer
);


--
-- Name: articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE articles_id_seq OWNED BY articles.id;


--
-- Name: cats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cats (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cats_id_seq OWNED BY cats.id;


--
-- Name: feeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feeds (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    source_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    last_modified timestamp without time zone,
    last_crawled timestamp without time zone,
    articles_count integer DEFAULT 0 NOT NULL
);


--
-- Name: feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feeds_id_seq OWNED BY feeds.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sources (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    source_type character varying(255),
    acronym character varying(255)
);


--
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sources_id_seq OWNED BY sources.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY articles ALTER COLUMN id SET DEFAULT nextval('articles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cats ALTER COLUMN id SET DEFAULT nextval('cats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feeds ALTER COLUMN id SET DEFAULT nextval('feeds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sources ALTER COLUMN id SET DEFAULT nextval('sources_id_seq'::regclass);


--
-- Name: articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- Name: cats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cats
    ADD CONSTRAINT cats_pkey PRIMARY KEY (id);


--
-- Name: feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feeds
    ADD CONSTRAINT feeds_pkey PRIMARY KEY (id);


--
-- Name: sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: articles_summary_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX articles_summary_idx ON articles USING gin (to_tsvector('simple'::regconfig, summary));


--
-- Name: articles_title_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX articles_title_idx ON articles USING gin (to_tsvector('simple'::regconfig, (title)::text));


--
-- Name: index_articles_cats_on_article_id_and_cat_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_articles_cats_on_article_id_and_cat_id ON articles_cats USING btree (article_id, cat_id);


--
-- Name: index_articles_on_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_articles_on_feed_id ON articles USING btree (feed_id);


--
-- Name: index_feeds_on_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_feeds_on_source_id ON feeds USING btree (source_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20141021093033');

INSERT INTO schema_migrations (version) VALUES ('20141021093103');

INSERT INTO schema_migrations (version) VALUES ('20141021093130');

INSERT INTO schema_migrations (version) VALUES ('20141022151827');

INSERT INTO schema_migrations (version) VALUES ('20141022161715');

INSERT INTO schema_migrations (version) VALUES ('20141024095320');

INSERT INTO schema_migrations (version) VALUES ('20141028115147');

INSERT INTO schema_migrations (version) VALUES ('20141104171500');

INSERT INTO schema_migrations (version) VALUES ('20141104172252');

INSERT INTO schema_migrations (version) VALUES ('20141105110903');

INSERT INTO schema_migrations (version) VALUES ('20141105143003');

INSERT INTO schema_migrations (version) VALUES ('20141105181105');

INSERT INTO schema_migrations (version) VALUES ('20141204154917');

INSERT INTO schema_migrations (version) VALUES ('20141206171057');

INSERT INTO schema_migrations (version) VALUES ('20141209174759');

INSERT INTO schema_migrations (version) VALUES ('20150106170009');

INSERT INTO schema_migrations (version) VALUES ('20150106170017');

INSERT INTO schema_migrations (version) VALUES ('20150108141909');

INSERT INTO schema_migrations (version) VALUES ('20150226212314');

INSERT INTO schema_migrations (version) VALUES ('20150319231227');

INSERT INTO schema_migrations (version) VALUES ('20150320012449');

INSERT INTO schema_migrations (version) VALUES ('20150328144810');

INSERT INTO schema_migrations (version) VALUES ('20150328150826');

INSERT INTO schema_migrations (version) VALUES ('20150328152556');

INSERT INTO schema_migrations (version) VALUES ('20150328165413');

INSERT INTO schema_migrations (version) VALUES ('20150420125533');

