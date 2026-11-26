--
-- PostgreSQL database dump
--

\restrict 31LOrA3SQUsknuvGSNPqQtGBo5lIyfD4EB3lLK1i3LLOzpawITVV5ngO1uz4NFx

-- Dumped from database version 18.7 (3190d2f)
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: lock_enrollment_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lock_enrollment_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(313, 11);
    RETURN NULL;
END;
$$;


--
-- Name: validate_enrollment(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_enrollment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    target_schedule schedules%ROWTYPE;
    enrolled_count INTEGER;
BEGIN
    IF NEW.status = 'Dropped' THEN
        RETURN NEW;
    END IF;

    SELECT *
    INTO target_schedule
    FROM schedules
    WHERE schedule_id = NEW.schedule_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Schedule not found.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM enrollments e
        JOIN schedules sc
            ON e.schedule_id = sc.schedule_id
        WHERE e.student_id = NEW.student_id
          AND sc.subject_id = target_schedule.subject_id
          AND e.status = 'Enrolled'
          AND e.enrollment_id IS DISTINCT FROM NEW.enrollment_id
    ) THEN
        RAISE EXCEPTION
            'Student is already enrolled in this subject.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM enrollments e
        JOIN schedules sc
            ON e.schedule_id = sc.schedule_id
        WHERE e.student_id = NEW.student_id
          AND e.status = 'Enrolled'
          AND e.enrollment_id IS DISTINCT FROM NEW.enrollment_id
          AND sc.day_of_week = target_schedule.day_of_week
          AND sc.start_time < target_schedule.end_time
          AND sc.end_time > target_schedule.start_time
    ) THEN
        RAISE EXCEPTION
            'Schedule conflict detected.';
    END IF;

    SELECT COUNT(*)
    INTO enrolled_count
    FROM enrollments
    WHERE schedule_id = NEW.schedule_id
      AND status = 'Enrolled'
      AND enrollment_id IS DISTINCT FROM NEW.enrollment_id;

    IF enrolled_count >= target_schedule.capacity THEN
        RAISE EXCEPTION
            'No available slots remaining.';
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: validate_enrollment_grade(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_enrollment_grade() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    enrollment_status VARCHAR(20);
BEGIN
    SELECT status
    INTO enrollment_status
    FROM enrollments
    WHERE enrollment_id = NEW.enrollment_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Enrollment not found.';
    END IF;

    IF enrollment_status <> 'Enrolled' THEN
        RAISE EXCEPTION
            'Cannot assign a grade without an active enrollment.';
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: validate_schedule_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_schedule_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    enrolled_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO enrolled_count
    FROM enrollments
    WHERE schedule_id = OLD.schedule_id
      AND status = 'Enrolled';

    IF NEW.capacity < enrolled_count THEN
        RAISE EXCEPTION
            'Capacity cannot be lower than enrolled students.';
    END IF;

    IF enrolled_count > 0 AND (
        NEW.subject_id IS DISTINCT FROM OLD.subject_id
        OR NEW.day_of_week IS DISTINCT FROM OLD.day_of_week
        OR NEW.start_time IS DISTINCT FROM OLD.start_time
        OR NEW.end_time IS DISTINCT FROM OLD.end_time
    ) THEN
        RAISE EXCEPTION
            'Cannot change class times or subject while students are enrolled.';
    END IF;

    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollments (
    enrollment_id integer NOT NULL,
    student_id integer NOT NULL,
    schedule_id integer NOT NULL,
    enrollment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status character varying(20) DEFAULT 'Enrolled'::character varying NOT NULL,
    CONSTRAINT enrollments_status_check CHECK (((status)::text = ANY ((ARRAY['Enrolled'::character varying, 'Dropped'::character varying])::text[])))
);
ALTER TABLE ONLY public.enrollments ALTER COLUMN enrollment_id SET (pg_attver=40115696);
ALTER TABLE ONLY public.enrollments ALTER COLUMN student_id SET (pg_attver=40115696);
ALTER TABLE ONLY public.enrollments ALTER COLUMN schedule_id SET (pg_attver=40115696);
ALTER TABLE ONLY public.enrollments ALTER COLUMN enrollment_date SET (pg_attver=40115696);
ALTER TABLE ONLY public.enrollments ALTER COLUMN status SET (pg_attver=40115696);


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules (
    schedule_id integer NOT NULL,
    subject_id integer NOT NULL,
    day_of_week character varying(15) NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    room character varying(50) NOT NULL,
    capacity integer NOT NULL,
    CONSTRAINT schedules_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT schedules_check CHECK ((end_time > start_time)),
    CONSTRAINT schedules_day_of_week_check CHECK (((day_of_week)::text = ANY ((ARRAY['Monday'::character varying, 'Tuesday'::character varying, 'Wednesday'::character varying, 'Thursday'::character varying, 'Friday'::character varying, 'Saturday'::character varying, 'Sunday'::character varying])::text[])))
);
ALTER TABLE ONLY public.schedules ALTER COLUMN schedule_id SET (pg_attver=38544936);
ALTER TABLE ONLY public.schedules ALTER COLUMN subject_id SET (pg_attver=38544936);
ALTER TABLE ONLY public.schedules ALTER COLUMN day_of_week SET (pg_attver=38544936);
ALTER TABLE ONLY public.schedules ALTER COLUMN start_time SET (pg_attver=38544936);
ALTER TABLE ONLY public.schedules ALTER COLUMN end_time SET (pg_attver=38544936);
ALTER TABLE ONLY public.schedules ALTER COLUMN room SET (pg_attver=38544936);
ALTER TABLE ONLY public.schedules ALTER COLUMN capacity SET (pg_attver=38544936);


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subjects (
    subject_id integer NOT NULL,
    subject_code character varying(20) NOT NULL,
    subject_name character varying(150) NOT NULL,
    units integer NOT NULL,
    CONSTRAINT subjects_units_check CHECK ((units > 0))
);
ALTER TABLE ONLY public.subjects ALTER COLUMN subject_id SET (pg_attver=38362312);
ALTER TABLE ONLY public.subjects ALTER COLUMN subject_code SET (pg_attver=38362312);
ALTER TABLE ONLY public.subjects ALTER COLUMN subject_name SET (pg_attver=38362312);
ALTER TABLE ONLY public.subjects ALTER COLUMN units SET (pg_attver=38362312);


--
-- Name: available_schedules; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.available_schedules AS
 SELECT sc.schedule_id,
    sc.subject_id,
    s.subject_code,
    s.subject_name,
    sc.day_of_week,
    sc.start_time,
    sc.end_time,
    sc.room,
    sc.capacity,
    (count(e.enrollment_id))::integer AS enrolled_students,
    ((sc.capacity - count(e.enrollment_id)))::integer AS available_slots
   FROM ((public.schedules sc
     JOIN public.subjects s ON ((sc.subject_id = s.subject_id)))
     LEFT JOIN public.enrollments e ON (((sc.schedule_id = e.schedule_id) AND ((e.status)::text = 'Enrolled'::text))))
  GROUP BY sc.schedule_id, sc.subject_id, s.subject_code, s.subject_name, sc.day_of_week, sc.start_time, sc.end_time, sc.room, sc.capacity;


--
-- Name: directory_student_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directory_student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollment_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollment_grades (
    grade_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    grade numeric(5,2) NOT NULL,
    date_recorded timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT enrollment_grades_grade_check CHECK (((grade >= (0)::numeric) AND (grade <= (100)::numeric)))
);
ALTER TABLE ONLY public.enrollment_grades ALTER COLUMN grade_id SET (pg_attver=40802376);
ALTER TABLE ONLY public.enrollment_grades ALTER COLUMN enrollment_id SET (pg_attver=40802376);
ALTER TABLE ONLY public.enrollment_grades ALTER COLUMN grade SET (pg_attver=40802376);
ALTER TABLE ONLY public.enrollment_grades ALTER COLUMN date_recorded SET (pg_attver=40802376);


--
-- Name: enrollment_grades_grade_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.enrollment_grades ALTER COLUMN grade_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.enrollment_grades_grade_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: enrollments_enrollment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.enrollments ALTER COLUMN enrollment_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.enrollments_enrollment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grades (
    grade_id integer NOT NULL,
    student_id integer NOT NULL,
    subject character varying(100) NOT NULL,
    score numeric(5,2) NOT NULL,
    CONSTRAINT grades_score_check CHECK (((score >= (0)::numeric) AND (score <= (100)::numeric)))
);
ALTER TABLE ONLY public.grades ALTER COLUMN grade_id SET (pg_attver=37496864);
ALTER TABLE ONLY public.grades ALTER COLUMN student_id SET (pg_attver=37496864);
ALTER TABLE ONLY public.grades ALTER COLUMN subject SET (pg_attver=37496864);
ALTER TABLE ONLY public.grades ALTER COLUMN score SET (pg_attver=37496864);


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.programs (
    program_id integer NOT NULL,
    program_code character varying(10) NOT NULL,
    program_name character varying(100) NOT NULL
);


--
-- Name: schedules_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.schedules ALTER COLUMN schedule_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.schedules_schedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    student_id integer NOT NULL,
    student_name character varying(100) NOT NULL,
    program_id integer,
    school_id character varying(30),
    image character varying(255),
    year_level integer,
    age integer,
    hobby character varying(100),
    height numeric(6,2),
    email character varying(255),
    favorite_subject character varying(100),
    is_favorite boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);
ALTER TABLE ONLY public.students ALTER COLUMN school_id SET (pg_attver=38111976);
ALTER TABLE ONLY public.students ALTER COLUMN image SET (pg_attver=38112424);
ALTER TABLE ONLY public.students ALTER COLUMN year_level SET (pg_attver=38112872);
ALTER TABLE ONLY public.students ALTER COLUMN age SET (pg_attver=38113744);
ALTER TABLE ONLY public.students ALTER COLUMN hobby SET (pg_attver=38114608);
ALTER TABLE ONLY public.students ALTER COLUMN height SET (pg_attver=38115056);
ALTER TABLE ONLY public.students ALTER COLUMN email SET (pg_attver=38115928);
ALTER TABLE ONLY public.students ALTER COLUMN favorite_subject SET (pg_attver=38116800);
ALTER TABLE ONLY public.students ALTER COLUMN is_favorite SET (pg_attver=38117704);
ALTER TABLE ONLY public.students ALTER COLUMN is_active SET (pg_attver=38119096);


--
-- Name: student_academic_records; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.student_academic_records AS
 SELECT e.enrollment_id,
    st.student_id,
    st.school_id,
    st.student_name,
    su.subject_code,
    su.subject_name,
    su.units,
    sc.day_of_week,
    sc.start_time,
    sc.end_time,
    sc.room,
    e.status AS enrollment_status,
    g.grade,
        CASE
            WHEN (g.grade IS NULL) THEN 'Not Yet Graded'::text
            WHEN (g.grade >= (75)::numeric) THEN 'Passed'::text
            ELSE 'Failed'::text
        END AS remarks
   FROM ((((public.enrollments e
     JOIN public.students st ON ((e.student_id = st.student_id)))
     JOIN public.schedules sc ON ((e.schedule_id = sc.schedule_id)))
     JOIN public.subjects su ON ((sc.subject_id = su.subject_id)))
     LEFT JOIN public.enrollment_grades g ON ((e.enrollment_id = g.enrollment_id)));


--
-- Name: student_grade_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.student_grade_details AS
 SELECT g.grade_id,
    g.enrollment_id,
    e.student_id,
    st.school_id,
    st.student_name,
    su.subject_code,
    su.subject_name,
    g.grade,
        CASE
            WHEN (g.grade >= (75)::numeric) THEN 'Passed'::text
            ELSE 'Failed'::text
        END AS remarks,
    e.status AS enrollment_status,
    g.date_recorded
   FROM ((((public.enrollment_grades g
     JOIN public.enrollments e ON ((g.enrollment_id = e.enrollment_id)))
     JOIN public.students st ON ((e.student_id = st.student_id)))
     JOIN public.schedules sc ON ((e.schedule_id = sc.schedule_id)))
     JOIN public.subjects su ON ((sc.subject_id = su.subject_id)));


--
-- Name: subjects_subject_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.subjects ALTER COLUMN subject_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.subjects_subject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: enrollment_grades enrollment_grades_enrollment_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment_grades
    ADD CONSTRAINT enrollment_grades_enrollment_id_key UNIQUE (enrollment_id);


--
-- Name: enrollment_grades enrollment_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment_grades
    ADD CONSTRAINT enrollment_grades_pkey PRIMARY KEY (grade_id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (enrollment_id);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (grade_id);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (program_id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (schedule_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);


--
-- Name: students students_school_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_school_id_key UNIQUE (school_id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (subject_id);


--
-- Name: subjects subjects_subject_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_subject_code_key UNIQUE (subject_code);


--
-- Name: students_school_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX students_school_id_unique ON public.students USING btree (school_id);


--
-- Name: unique_active_enrollment; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_active_enrollment ON public.enrollments USING btree (student_id, schedule_id) WHERE ((status)::text = 'Enrolled'::text);


--
-- Name: enrollment_grades check_enrollment_grade; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_enrollment_grade BEFORE INSERT OR UPDATE ON public.enrollment_grades FOR EACH ROW EXECUTE FUNCTION public.validate_enrollment_grade();


--
-- Name: enrollments check_enrollment_rules; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_enrollment_rules BEFORE INSERT OR UPDATE ON public.enrollments FOR EACH ROW EXECUTE FUNCTION public.validate_enrollment();


--
-- Name: schedules check_schedule_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_schedule_update BEFORE UPDATE ON public.schedules FOR EACH ROW EXECUTE FUNCTION public.validate_schedule_update();


--
-- Name: enrollments enrollment_write_lock; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER enrollment_write_lock BEFORE INSERT OR DELETE OR UPDATE ON public.enrollments FOR EACH STATEMENT EXECUTE FUNCTION public.lock_enrollment_changes();


--
-- Name: schedules schedule_write_lock; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER schedule_write_lock BEFORE INSERT OR DELETE OR UPDATE ON public.schedules FOR EACH STATEMENT EXECUTE FUNCTION public.lock_enrollment_changes();


--
-- Name: enrollment_grades enrollment_grades_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment_grades
    ADD CONSTRAINT enrollment_grades_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(enrollment_id);


--
-- Name: enrollments enrollments_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules(schedule_id);


--
-- Name: enrollments enrollments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: grades grades_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: schedules schedules_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(subject_id);


--
-- Name: students students_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.programs(program_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 31LOrA3SQUsknuvGSNPqQtGBo5lIyfD4EB3lLK1i3LLOzpawITVV5ngO1uz4NFx