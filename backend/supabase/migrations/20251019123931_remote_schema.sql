revoke delete on table "public"."questions" from "anon";

revoke insert on table "public"."questions" from "anon";

revoke references on table "public"."questions" from "anon";

revoke select on table "public"."questions" from "anon";

revoke trigger on table "public"."questions" from "anon";

revoke truncate on table "public"."questions" from "anon";

revoke update on table "public"."questions" from "anon";

revoke delete on table "public"."questions" from "authenticated";

revoke insert on table "public"."questions" from "authenticated";

revoke references on table "public"."questions" from "authenticated";

revoke select on table "public"."questions" from "authenticated";

revoke trigger on table "public"."questions" from "authenticated";

revoke truncate on table "public"."questions" from "authenticated";

revoke update on table "public"."questions" from "authenticated";

revoke delete on table "public"."questions" from "service_role";

revoke insert on table "public"."questions" from "service_role";

revoke references on table "public"."questions" from "service_role";

revoke select on table "public"."questions" from "service_role";

revoke trigger on table "public"."questions" from "service_role";

revoke truncate on table "public"."questions" from "service_role";

revoke update on table "public"."questions" from "service_role";

revoke delete on table "public"."quran_words" from "anon";

revoke insert on table "public"."quran_words" from "anon";

revoke references on table "public"."quran_words" from "anon";

revoke select on table "public"."quran_words" from "anon";

revoke trigger on table "public"."quran_words" from "anon";

revoke truncate on table "public"."quran_words" from "anon";

revoke update on table "public"."quran_words" from "anon";

revoke delete on table "public"."quran_words" from "authenticated";

revoke insert on table "public"."quran_words" from "authenticated";

revoke references on table "public"."quran_words" from "authenticated";

revoke select on table "public"."quran_words" from "authenticated";

revoke trigger on table "public"."quran_words" from "authenticated";

revoke truncate on table "public"."quran_words" from "authenticated";

revoke update on table "public"."quran_words" from "authenticated";

revoke delete on table "public"."quran_words" from "service_role";

revoke insert on table "public"."quran_words" from "service_role";

revoke references on table "public"."quran_words" from "service_role";

revoke select on table "public"."quran_words" from "service_role";

revoke trigger on table "public"."quran_words" from "service_role";

revoke truncate on table "public"."quran_words" from "service_role";

revoke update on table "public"."quran_words" from "service_role";

revoke delete on table "public"."verses" from "anon";

revoke insert on table "public"."verses" from "anon";

revoke references on table "public"."verses" from "anon";

revoke select on table "public"."verses" from "anon";

revoke trigger on table "public"."verses" from "anon";

revoke truncate on table "public"."verses" from "anon";

revoke update on table "public"."verses" from "anon";

revoke delete on table "public"."verses" from "authenticated";

revoke insert on table "public"."verses" from "authenticated";

revoke references on table "public"."verses" from "authenticated";

revoke select on table "public"."verses" from "authenticated";

revoke trigger on table "public"."verses" from "authenticated";

revoke truncate on table "public"."verses" from "authenticated";

revoke update on table "public"."verses" from "authenticated";

revoke delete on table "public"."verses" from "service_role";

revoke insert on table "public"."verses" from "service_role";

revoke references on table "public"."verses" from "service_role";

revoke select on table "public"."verses" from "service_role";

revoke trigger on table "public"."verses" from "service_role";

revoke truncate on table "public"."verses" from "service_role";

revoke update on table "public"."verses" from "service_role";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.bulk_update_verse_pages(updates verse_page_update[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Loop through the array and update each row
  FOR i IN 1..array_length(updates, 1) LOOP
    UPDATE public.verses
    SET page_number = updates[i].p_num
    WHERE id = updates[i].verse_id;
  END LOOP;
END;
$function$
;



