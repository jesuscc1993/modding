package net.fabricmc.buildertools;

import net.minecraft.item.Items;
import net.minecraft.item.ToolMaterial;
import net.minecraft.recipe.Ingredient;

public class BuilderToolMaterial implements ToolMaterial {
	public static final BuilderToolMaterial INSTANCE = new BuilderToolMaterial();

	@Override
	public int getDurability() {
		return 65535;
	}

	@Override
	public float getMiningSpeedMultiplier() {
		return 100.0F;
	}

	@Override
	public float getAttackDamage() {
		return 0.0F;
	}

	@Override
	public int getMiningLevel() {
		return 3;
	}

	@Override
	public int getEnchantability() {
		return 22;
	}

	@Override
	public Ingredient getRepairIngredient() {
		return Ingredient.ofItems(Items.STICK);
	}
}
