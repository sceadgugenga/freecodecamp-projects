--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)
-- Dumped by pg_dump version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE number_guess;
--
-- Name: number_guess; Type: DATABASE; Schema: -; Owner: freecodecamp
--

CREATE DATABASE number_guess WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';


ALTER DATABASE number_guess OWNER TO freecodecamp;

\connect number_guess

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: game_history; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.game_history (
    history_id integer NOT NULL,
    user_id integer,
    games_played integer,
    best_game integer
);


ALTER TABLE public.game_history OWNER TO freecodecamp;

--
-- Name: game_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.game_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.game_history_history_id_seq OWNER TO freecodecamp;

--
-- Name: game_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.game_history_history_id_seq OWNED BY public.game_history.history_id;


--
-- Name: usernames; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.usernames (
    user_id integer NOT NULL,
    username character varying(22) NOT NULL
);


ALTER TABLE public.usernames OWNER TO freecodecamp;

--
-- Name: usernames_user_id_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.usernames_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usernames_user_id_seq OWNER TO freecodecamp;

--
-- Name: usernames_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.usernames_user_id_seq OWNED BY public.usernames.user_id;


--
-- Name: game_history history_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.game_history ALTER COLUMN history_id SET DEFAULT nextval('public.game_history_history_id_seq'::regclass);


--
-- Name: usernames user_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.usernames ALTER COLUMN user_id SET DEFAULT nextval('public.usernames_user_id_seq'::regclass);


--
-- Data for Name: game_history; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--



--
-- Data for Name: usernames; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--



--
-- Name: game_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.game_history_history_id_seq', 8, true);


--
-- Name: usernames_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.usernames_user_id_seq', 19, true);


--
-- Name: game_history game_history_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.game_history
    ADD CONSTRAINT game_history_pkey PRIMARY KEY (history_id);


--
-- Name: usernames usernames_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.usernames
    ADD CONSTRAINT usernames_pkey PRIMARY KEY (user_id);


--
-- Name: usernames usernames_username_key; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.usernames
    ADD CONSTRAINT usernames_username_key UNIQUE (username);


--
-- Name: game_history game_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.game_history
    ADD CONSTRAINT game_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.usernames(user_id);


--
-- PostgreSQL database dump complete
--





