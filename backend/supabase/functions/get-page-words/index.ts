import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Define the expected structure of the returned data
interface QuranWord {
  id: number;
  position: number;
  arabic_text: string;
}

interface QuranVerse {
  id: number;
  surah_number: number;
  ayah_number: number;
  quran_words: QuranWord[];
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { pageNumber } = await req.json();
    if (!pageNumber || typeof pageNumber !== "number") {
      return new Response(JSON.stringify({ error: "Invalid pageNumber" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing auth header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );

    // This query now works because 'verses' has 'page_number'
    const { data, error } = await supabase
      .from("verses")
      .select(`
        id,
        surah_number,
        ayah_number,
        quran_words (
          id,
          position,
          arabic_text
        )
      `)
      .eq("page_number", pageNumber)
      .order("ayah_number", { ascending: true })
      .order("position", { foreignTable: "quran_words", ascending: true });

    if (error) throw error;

    const pageData: QuranVerse[] = data || [];

    return new Response(JSON.stringify({ verses: pageData }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    // Handle errors gracefully
    const errorMessage = error instanceof Error
      ? error.message
      : "An unknown error occurred";
    console.error("Error in generate-quiz function:", error); // Log error
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
