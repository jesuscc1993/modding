package net.fabricmc.buildertools;

import net.fabricmc.api.ModInitializer;
import net.minecraft.item.ToolItem;
import net.minecraft.util.Identifier;
import net.minecraft.util.registry.Registry;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import static net.fabricmc.buildertools.BuilderToolConstants.modId;
import static net.fabricmc.buildertools.BuilderToolItems.*;

public class BuilderToolsMod implements ModInitializer {
	public static final Logger LOGGER = LogManager.getLogger(modId);

	@Override
	public void onInitialize() {
		addTool(BUILDER_TOOL_AXE, "builder_axe");
		addTool(BUILDER_TOOL_HOE, "builder_hoe");
		addTool(BUILDER_TOOL_PICKAXE, "builder_pickaxe");
		addTool(BUILDER_TOOL_SHOVEL, "builder_shovel");
		addTool(BUILDER_TOOL_SWORD, "builder_sword");

		LOGGER.info("[BuilderTools] Mod loaded.");
	}

	private void addTool(ToolItem toolItem, String name) {
		Registry.register(Registry.ITEM, new Identifier(modId, name), toolItem);
	}
}
