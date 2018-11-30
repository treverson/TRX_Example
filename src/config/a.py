import json

id = 0
result = []
with open("a", "r") as f:
    for line in f:
        line = line.replace("\n", "")
        item  = line.replace("\t", " ").split(" ", 1)
        a = item[0]
        b = item[1]
        result.append({"id": id, "image_id": a, "name": b})
        id += 1

print(json.dumps(result, indent=2))

