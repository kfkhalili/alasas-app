import * as fs from "fs";
import * as path from "path";
import csv from "csv-parser";

interface PageRow {
    page_number: number;
    line_number: number;
    line_type: string;
    is_centered: number;
    first_word_id: number | null;
    last_word_id: number | null;
    surah_number: number | null;
}

const csvFilePath = path.join(__dirname, "../data/pages.csv");
const jsonFilePath = path.join(__dirname, "../data/mushaf-pages.json");
const results: PageRow[] = [];

fs.createReadStream(csvFilePath)
    .pipe(
        csv({
            mapValues: ({ header, value }) => {
                const intHeaders = [
                    "page_number",
                    "line_number",
                    "is_centered",
                    "first_word_id",
                    "last_word_id",
                    "surah_number",
                ];
                if (intHeaders.includes(header)) {
                    return value === "" ? null : parseInt(value, 10);
                }
                return value;
            },
        }),
    )
    .on("data", (data) => results.push(data as PageRow))
    .on("end", () => {
        try {
            fs.writeFileSync(jsonFilePath, JSON.stringify(results, null, 2));
            console.log(
                `Successfully converted ${csvFilePath} to ${jsonFilePath}`,
            );
        } catch (err) {
            console.error("Error writing JSON file:", err);
        }
    })
    .on("error", (err) => {
        console.error("Error reading CSV file:", err);
    });
