include(CForgeTargetAddWarnings)

cforge_target_add_warnings(toto CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/my-warnings.json")
cforge_target_add_warnings(toto)
