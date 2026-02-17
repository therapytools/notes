# Copilot instructions for note templates

When adding or changing note types in `src/templates.js` (`staffNoteOptions`):

1. Always sync runtime fixtures:
   - Run `npm run fixtures:sync`
2. If the new note needs non-default setup (e.g., `dtc`, `toc`, required dropdown/input values), update the generated fixture entry in `tests/note-fixtures.json`.
3. Validate before finishing:
   - Run `npm run smoke`
   - Run `npm run fixtures`

Do not complete note-type changes without updating fixtures and passing smoke/runtime checks.
