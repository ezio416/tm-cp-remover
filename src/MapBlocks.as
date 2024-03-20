// c 2024-03-19
// m 2024-03-19

bool       loadingMapBlocks = false;
Block@[]   mapBlocks;

void ClearMapBlocks() {
    if (mapBlocks.Length == 0)
        return;

    mapBlocks = {};
}

void LoadMapBlocks() {
    if (loadingMapBlocks)
        return;

    loadingMapBlocks = true;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null) {
        loadingMapBlocks = false;
        return;
    }

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null) {
        loadingMapBlocks = false;
        return;
    }

    ClearMapBlocks();

    const uint64 now = Time::Now;

    for (uint i = 0; i < Map.Blocks.Length; i++) {
        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        Block@ block = Block(Map.Blocks[i]);

        if (block.id.Value != stadiumGrassId)
            mapBlocks.InsertLast(block);
    }

    loadingMapBlocks = false;
}

void Tab_MapBlocks() {
    if (!UI::BeginTabItem("Map Blocks"))
        return;

    UI::BeginDisabled(loadingMapBlocks);
    if (UI::Button("Load Map Blocks"))
        startnew(LoadMapBlocks);
    UI::EndDisabled();

    UI::SameLine();
    UI::Text("Loaded Blocks: " + mapBlocks.Length);

    if (UI::BeginTable("##table-map-blocks", 11, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("id");
        UI::TableSetupColumn("id value", UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableSetupColumn("author",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("color",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("dir",      UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("ghost",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("ground",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("variant",  UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("free",     UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("coord",    UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("wp type",  UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(mapBlocks.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Block@ block = mapBlocks[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::BeginDisabled(block.block is null);
                if (UI::Selectable(block.id.GetName() + "##" + i, false, UI::SelectableFlags::SpanAllColumns))
                    ExploreNod(block.id.GetName(), block.block);
                UI::EndDisabled();

                UI::TableNextColumn();
                UI::Text(IntToHex(block.id.Value));

                UI::TableNextColumn();
                UI::Text(block.author.GetName());

                UI::TableNextColumn();
                UI::Text(tostring(block.color));

                UI::TableNextColumn();
                UI::Text(tostring(block.direction));

                UI::TableNextColumn();
                UI::Text(tostring(block.ghost));

                UI::TableNextColumn();
                UI::Text(tostring(block.ground));

                UI::TableNextColumn();
                UI::Text(tostring(block.variant));

                UI::TableNextColumn();
                UI::Text(tostring(block.free));

                UI::TableNextColumn();
                UI::Text(tostring(block.coord));

                UI::TableNextColumn();
                UI::Text(tostring(block.waypointType));
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}