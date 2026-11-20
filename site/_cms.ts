import create from "@lumeland/cms";

const cms = create();

cms.collection("posts: ブログ記事", "src:blog/*.md", [
	{
		name: "title",
		type: "text",
		label: "タイトル",
		attributes: { required: true },
	},
	{
		name: "date",
		type: "date",
		label: "公開日",
		attributes: { required: true },
	},
	{
		name: "summary",
		type: "textarea",
		label: "概要",
	},
	{
		name: "content",
		type: "markdown",
		label: "本文",
	},
]);

export default cms;
