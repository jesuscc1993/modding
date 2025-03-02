costs = [1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 25, 30, 33, 35, 39, 40, 44, 45, 50, 55, 60]
multipliers = [25, 33, 50, 67, 75]

def generate_lists():
  for multiplier in multipliers:
    humanity_list, tinkerer_list = generate_list(multiplier)

    with open(f'../r6/tweaks/cyberware-cost-{multiplier}.yaml', 'w') as file:
      write_costs(file, humanity_list)
      write_costs(file, tinkerer_list)

def generate_list(multiplier):
  base_costs = {}
  tinkerer_costs = {}

  for cost in costs:
    new_cost = max(round(cost * multiplier / 100), 1)
    new_tinkerer_cost = (cost - new_cost) * -1

    add_cost(f'Variants.Humanity{cost}Cost_inline', base_costs, new_cost)
    add_cost(f'Variants.Humanity{cost}CostTinkererVariant_inline', tinkerer_costs, new_tinkerer_cost)

  return base_costs, tinkerer_costs

def add_cost(prefix, cost_dict, new_cost):
  cost_dict[f'{prefix}1.value'] = new_cost
  cost_dict[f'{prefix}2.value'] = new_cost

def write_costs(file, costs):
  for key, value in costs.items():
    file.write(f'{key}: {value}\n')

generate_lists()
