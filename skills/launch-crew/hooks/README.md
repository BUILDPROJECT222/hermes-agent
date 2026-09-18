# Hook: sync-crew-skills

Menarik balik perbaikan skill yang ditulis agen ke dalam repo git.

## Kenapa perlu

Sinkronisasi bawaan Hermes searah: repo → `~/.hermes/skills/`, dan ia **melewati** apa pun
yang sudah diubah agen (`user-modified, keeping`). Jadi ketika agen memperbaiki instruksinya
sendiri setelah sebuah run, perbaikan itu tidak pernah sampai ke git dan hilang saat reinstall.
Hook ini membawanya ke arah sebaliknya, di akhir tiap sesi.

Ini bukan hipotetis: pada run pertama `market-research` v2, agen menambahkan tiga jebakan baru
plus fallback `curl` ke salinan terpasangnya. Perbaikannya benar, dan nyaris terdampar.

## Yang dia lakukan, dan tidak lakukan

- **Menyalin** `SKILL.md` yang berubah dari `~/.hermes/skills/launch-crew/` ke repo.
- **Tidak commit dan tidak push.** Perubahan yang dibuat agen terhadap instruksinya sendiri
  justru jenis yang harus dibaca manusia sebelum diterbitkan. `git status` jadi antrean tinjauan.
- **Tidak pernah membuat skill baru** di repo — hanya memperbarui yang sudah ada.
- **Menolak yang rusak.** Frontmatter divalidasi dulu: YAML harus terparse, `name` dan
  `description` harus ada, `description` ≤ 60 karakter. Skill dengan frontmatter rusak berhenti
  termuat tanpa suara, jadi yang rusak dicatat di log dan tidak disalin.
- **Mengalah pada manusia.** Kalau berkas di repo lebih baru dari salinan terpasang, hook diam.

Log: `~/.hermes/agent-hooks/sync-crew-skills.log`

## Pemasangan

```bash
mkdir -p ~/.hermes/agent-hooks
cp skills/launch-crew/hooks/sync-crew-skills.sh ~/.hermes/agent-hooks/
chmod +x ~/.hermes/agent-hooks/sync-crew-skills.sh
```

Lalu di `~/.hermes/config.yaml`:

```yaml
hooks:
  on_session_end:
    - command: /Users/depi/.hermes/agent-hooks/sync-crew-skills.sh
      timeout: 30
```

## Persetujuan

Hermes tidak menjalankan shell hook sampai disetujui, satu persetujuan per pasangan
(event, perintah). Setujui lewat prompt TTY pada run interaktif berikutnya — jalankan `hermes`,
dan jawab prompt-nya.

Jangan pakai `hooks_auto_accept: true`. Itu menyetujui **semua** hook di masa depan, termasuk
yang ditulis agen untuk dirinya sendiri — dan agen ini memang bisa menulis berkas.
