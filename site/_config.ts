import lume from "@lumeland/lume";
import lumeCms from "@lumeland/plugin-cms";
import cms from "./_cms.ts";

const site = lume();

site.use(lumeCms({ cms }));

site.copy("styles.css");
site.copy("img");

site.filter("date", (value: Date) => {
	const year = value.getUTCFullYear();
	const month = String(value.getUTCMonth() + 1).padStart(2, "0");
	const day = String(value.getUTCDate()).padStart(2, "0");
	return `${year}.${month}.${day}`;
});

site.filter("isoDate", (value: Date) => value.toISOString().slice(0, 10));

export default site;
