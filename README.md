# n-high-lovelive

Crystalとhtmxで書かれた、N高ラブライブ同好会のホームページです。Discordから記事を管理できます。

# Requirements

Nix

# Usage

依存関係を解決します。
```bash
shards install
```

このプロジェクトはdirenvを使用しています。

`.envrc`に以下を追記します。
```
use flake

export DISCORD_TOKEN=
export GUILD_ID=
export FORUM_ID=
export KEMAL_ENV=production
```

ビルドします。
```bash
shards build --release
```
