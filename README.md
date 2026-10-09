## About this Repository

This is a Selene bundle defining tiles and entities as seen in the open source online
roleplaying game Illarion. This data was backported to support the original version of the game on the Gobaith map.

This bundle depends on an asset bundle providing the graphics and visual definitions referenced in its data, i.e. it is
not self-contained. Due to licensing restrictions, any graphics or related assets are not included.

The original sources used to derive this data can be found under https://github.com/Illarion-eV.

Add items in `server/data/illarion/items/`. This bundle's server entrypoint
generates their tile and entity definitions at runtime; no separate
item tile or entity JSON is needed. Existing `illarion:items/<item-name>` world identifiers are preserved.
Custom tile or entity JSON can still override the generated defaults. Visual definitions and textures
remain in the asset bundle.

The generator lives in `server/lua/lib/item_definitions.lua`. It handles registry edits, removals,
and reloads. Clients fetch the generated definitions through the normal registry endpoint.
Run its tests from the Selene workspace with:

```sh
lua bundles/illarion-gobaith-data/tests/item_definitions_test.lua
```
