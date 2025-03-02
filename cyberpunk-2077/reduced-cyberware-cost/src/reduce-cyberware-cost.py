costs = [
  1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 25, 30, 33, 35, 39, 40, 44, 45, 50, 55, 60
]
multipliers = [
  25, 33, 50, 67, 75
]

def generate_lists():
  for multiplier in multipliers:
    humanity_list, tinkerer_list = generate_list(multiplier)

    with open(f'../r6/tweaks/cyberware-cost-{multiplier}.yaml', 'w') as file:
      for key, value in humanity_list.items():
        file.write(f"{key}: {value}\n")

      for key, value in tinkerer_list.items():
        file.write(f"{key}: {value}\n")

def generate_list(multiplier):
  base_costs = {}
  tinkerer_costs = {}

  for cost in costs:
    new_cost = max(round(cost * multiplier / 100), 1)
    new_tinkerer_cost = (cost - new_cost) * -1

    prefix = f"Variants.Humanity{cost}Cost_inline"
    base_costs[f"{prefix}1.value"] = new_cost
    base_costs[f"{prefix}2.value"] = new_cost

    prefix = f"Variants.Humanity{cost}CostTinkererVariant_inline"
    tinkerer_costs[f"{prefix}1.value"] = new_tinkerer_cost
    tinkerer_costs[f"{prefix}2.value"] = new_tinkerer_cost

  return base_costs, tinkerer_costs

generate_lists()
