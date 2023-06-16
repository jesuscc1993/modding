package net.fabricmc.buildertools;

import net.minecraft.item.*;

public class BuilderToolItems {

	private static final Item.Settings toolsGroup = new Item.Settings().group(ItemGroup.TOOLS);
	private static final Item.Settings weaponsGroup = new Item.Settings().group(ItemGroup.COMBAT);

	public static ToolItem BUILDER_TOOL_SHOVEL = new ShovelItem(
			BuilderToolMaterial.INSTANCE, 1.5F, -3.0F, toolsGroup
	);

	public static ToolItem BUILDER_TOOL_SWORD = new SwordItem(
			BuilderToolMaterial.INSTANCE, 3, -2.4F, weaponsGroup
	);

	public static ToolItem BUILDER_TOOL_AXE = new CustomAxeItem(
			BuilderToolMaterial.INSTANCE, 6F, -3.2F, toolsGroup
	);

	public static ToolItem BUILDER_TOOL_HOE = new CustomHoeItem(
			BuilderToolMaterial.INSTANCE, 0, -3.0F, toolsGroup
	);

	public static ToolItem BUILDER_TOOL_PICKAXE = new CustomPickaxeItem(
			BuilderToolMaterial.INSTANCE, 1, -2.8F, toolsGroup
	);

	private static class CustomAxeItem extends AxeItem {
		public CustomAxeItem(ToolMaterial material, float attackDamage, float attackSpeed, Settings settings) {
			super(material, attackDamage, attackSpeed, settings);
		}
	}

	private static class CustomHoeItem extends HoeItem {
		public CustomHoeItem(ToolMaterial material, int attackDamage, float attackSpeed, Settings settings) {
			super(material, attackDamage, attackSpeed, settings);
		}
	}

	private static class CustomPickaxeItem extends PickaxeItem {
		public CustomPickaxeItem(ToolMaterial material, int attackDamage, float attackSpeed, Settings settings) {
			super(material, attackDamage, attackSpeed, settings);
		}
	}
}
