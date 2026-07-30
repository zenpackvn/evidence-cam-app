#!/usr/bin/env python3
"""Transpile a Pencil `.pen` design file into Flutter widget code.

The `.pen` format is a flexbox tree (`frame` / `text` / `icon` / `path` /
`ellipse` / `rectangle`). This emits a `PenBox` / `PenText` / `PenIcon` /
`PenPath` / `PenEllipse` tree (see `packages/ec_ui/lib/src/pen.dart`) that is a
1:1 mapping of it, so the generated screens land on the designer's exact pixel
values instead of hand-transcribed approximations.

Usage:
  python3 tool/pen2dart.py <design.pen> <out-dir>
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------- primitives


def color(value) -> str:
    """`#RRGGBB` / `#RRGGBBAA` -> a Dart `Color(0xAARRGGBB)` literal.

    Shapes that can only take a solid colour (paths, text, icons) collapse a
    gradient fill to its first stop.
    """
    if isinstance(value, dict):
        stops = value.get("colors") or [{"color": "#161616"}]
        value = stops[0]["color"]
    hex_ = str(value).lstrip("#")
    if len(hex_) == 3:
        hex_ = "".join(c * 2 for c in hex_)
    if len(hex_) == 6:
        return f"Color(0xFF{hex_.upper()})"
    rgb, alpha = hex_[:6], hex_[6:8]
    return f"Color(0x{alpha.upper()}{rgb.upper()})"


def num(value) -> str:
    """Dart double literal, trimmed of a pointless `.0`."""
    f = float(value)
    return str(int(f)) if f == int(f) else str(f)


def camel(kebab: str) -> str:
    head, *rest = kebab.split("-")
    return head + "".join(p[:1].upper() + p[1:] for p in rest)


def dart_str(text: str) -> str:
    body = text.replace("\\", r"\\").replace("'", r"\'").replace("$", r"\$")
    body = body.replace("\n", r"\n")
    return f"'{body}'"


WEIGHTS = {"normal": "w400", "bold": "w700"}


def weight(value) -> str:
    return "FontWeight." + WEIGHTS.get(str(value), f"w{value}")


def edge_insets(padding) -> str | None:
    """`.pen` padding is CSS order: scalar, [v, h] or [t, r, b, l]."""
    if padding is None:
        return None
    if not isinstance(padding, list):
        padding = [padding]
    if len(padding) == 1:
        t = r = b = l = padding[0]
    elif len(padding) == 2:
        t = b = padding[0]
        r = l = padding[1]
    else:
        t, r, b, l = padding[:4]
    if t == r == b == l:
        return None if t == 0 else f"EdgeInsets.all({num(t)})"
    if t == b and r == l:
        return (
            f"EdgeInsets.symmetric(vertical: {num(t)}, horizontal: {num(r)})"
        )
    return (
        f"EdgeInsets.fromLTRB({num(l)}, {num(t)}, {num(r)}, {num(b)})"
    )


MAIN = {
    "center": "MainAxisAlignment.center",
    "end": "MainAxisAlignment.end",
    "start": "MainAxisAlignment.start",
    "space_between": "MainAxisAlignment.spaceBetween",
    "space-between": "MainAxisAlignment.spaceBetween",
    "space_around": "MainAxisAlignment.spaceAround",
}
CROSS = {
    "center": "CrossAxisAlignment.center",
    "end": "CrossAxisAlignment.end",
    "start": "CrossAxisAlignment.start",
    "stretch": "CrossAxisAlignment.stretch",
}
ALIGN = {
    "center": "TextAlign.center",
    "right": "TextAlign.right",
    "left": "TextAlign.left",
}

FILL = "fill_container"


# ------------------------------------------------------------------- emitter


class Emitter:
    def __init__(self) -> None:
        self.icons: set[str] = set()
        self.images: set[str] = set()

    # -- helpers ----------------------------------------------------------
    def _fill_args(self, node: dict) -> list[str]:
        args: list[str] = []
        fill = node.get("fill")
        if isinstance(fill, str) and fill != "none":
            args.append(f"fill: const {color(fill)}")
        elif isinstance(fill, dict) and fill.get("enabled", True):
            if fill.get("type") == "image":
                url = fill["url"]
                self.images.add(url)
                asset = "assets/design/" + re.sub(r"^images/", "", url)
                fit = "BoxFit.cover" if fill.get("mode") == "fill" else "BoxFit.contain"
                args.append(f"image: const AssetImage('{asset}', package: 'ec_ui')")
                args.append(f"imageFit: {fit}")
            elif fill.get("type") == "gradient":
                stops = fill["colors"]
                colors = ", ".join(f"const {color(s['color'])}" for s in stops)
                positions = ", ".join(num(s["position"]) for s in stops)
                args.append(
                    "gradient: LinearGradient(colors: [%s], stops: const [%s])"
                    % (colors, positions)
                )
        if node.get("stroke"):
            args.append(f"stroke: const {color(node['stroke'])}")
            if node.get("strokeWidth", 1) != 1:
                args.append(f"strokeWidth: {num(node['strokeWidth'])}")
        radius = node.get("cornerRadius")
        if isinstance(radius, list):
            tl, tr, br, bl = (radius + radius[:1] * 3)[:4]
            args.append(
                "borderRadius: const BorderRadius.only("
                f"topLeft: Radius.circular({num(tl)}), "
                f"topRight: Radius.circular({num(tr)}), "
                f"bottomRight: Radius.circular({num(br)}), "
                f"bottomLeft: Radius.circular({num(bl)}))"
            )
        elif radius:
            args.append(f"radius: {num(radius)}")
        effect = node.get("effect")
        if isinstance(effect, dict) and effect.get("type") == "shadow":
            off = effect.get("offset", {})
            args.append(
                "shadows: const [BoxShadow("
                f"color: {color(effect['color'])}, "
                f"offset: Offset({num(off.get('x', 0))}, {num(off.get('y', 0))}), "
                f"blurRadius: {num(effect.get('blur', 0))})]"
            )
        if node.get("rotation"):
            args.append(f"rotation: {num(node['rotation'])}")
        return args

    def _size_args(self, node: dict, parent_axis: str | None) -> list[str]:
        """Width/height, translating `fill_container` per parent direction."""
        args = []
        w, h = node.get("width"), node.get("height")
        if isinstance(w, (int, float)):
            args.append(f"width: {num(w)}")
        elif w == FILL and parent_axis == "column":
            args.append("width: double.infinity")
        if isinstance(h, (int, float)):
            args.append(f"height: {num(h)}")
        elif h == FILL and parent_axis == "row":
            args.append("height: double.infinity")
        return args

    def _expands(self, node: dict, parent_axis: str | None) -> bool:
        if parent_axis == "row":
            return node.get("width") == FILL
        if parent_axis == "column":
            return node.get("height") == FILL
        return False

    # -- nodes ------------------------------------------------------------
    def frame(
        self,
        node: dict,
        parent_axis: str | None,
        depth: int,
        root: bool = False,
    ) -> str:
        # The root frame is the 390x844 artboard: on a device it is the whole
        # viewport, so its own size/rounding is design-file chrome, not UI.
        args = [] if root else self._size_args(node, parent_axis)
        args += self._fill_args({**node, "cornerRadius": None} if root else node)

        kids = node.get("children", [])
        flow = [k for k in kids if k.get("layoutPosition") != "absolute"]
        absolute = [k for k in kids if k.get("layoutPosition") == "absolute"]

        layout = node.get("layout")
        axis = {"vertical": "column", "none": "stack"}.get(layout, "row")
        if not flow and not absolute:
            axis = None

        pad = edge_insets(node.get("padding"))
        inner_args: list[str] = []
        if axis in ("row", "column"):
            inner_args.append(f"axis: PenAxis.{axis}")
            if node.get("gap"):
                inner_args.append(f"gap: {num(node['gap'])}")
            if node.get("justifyContent") in MAIN:
                inner_args.append(f"main: {MAIN[node['justifyContent']]}")
            if node.get("alignItems") in CROSS:
                inner_args.append(f"cross: {CROSS[node['alignItems']]}")
            hug = axis == "row" and node.get("width") not in (FILL,) and not isinstance(
                node.get("width"), (int, float)
            )
            hug = hug or (
                axis == "column"
                and node.get("height") not in (FILL,)
                and not isinstance(node.get("height"), (int, float))
            )
            if hug:
                inner_args.append("hugMain: true")
        elif axis == "stack":
            inner_args.append("axis: PenAxis.stack")
        if node.get("clip"):
            inner_args.append("clip: true")

        children_src = [self.node(k, axis, depth + 2) for k in flow]

        if absolute:
            # A frame that mixes auto-layout with absolutely placed children
            # becomes a Stack: the flow content fills it, the rest is pinned.
            body: list[str] = []
            if children_src:
                flow_box = self._box(
                    inner_args + ([f"padding: {pad}"] if pad else []),
                    children_src,
                    depth + 4,
                )
                body.append(f"Positioned.fill(child: {flow_box})")
            frame_size = (node.get("width"), node.get("height")) if root else None
            for kid in absolute:
                body.append(self._positioned(kid, depth + 2, frame_size))
            return self._box(args + ["axis: PenAxis.stack"], body, depth)

        if pad:
            inner_args.append(f"padding: {pad}")
        return self._box(args + inner_args, children_src, depth)

    def _positioned(self, node: dict, depth: int, frame=None) -> str:
        """Pin an absolutely-placed child.

        Inside the root artboard the frame is the device viewport, whose height
        is not 844 — so anchor each decoration to the edge the designer placed
        it against instead of always measuring from the top-left.
        """
        inner = self.node(node, None, depth + 2)
        x, y = node.get("x", 0), node.get("y", 0)
        w, h = node.get("width", 0), node.get("height", 0)
        edges = [f"left: {num(x)}", f"top: {num(y)}"]
        if frame and isinstance(frame[0], (int, float)) and x + w / 2 > frame[0] / 2:
            edges[0] = f"right: {num(frame[0] - x - (w if isinstance(w, (int, float)) else 0))}"
        if frame and isinstance(frame[1], (int, float)) and y + h / 2 > frame[1] / 2:
            edges[1] = f"bottom: {num(frame[1] - y - (h if isinstance(h, (int, float)) else 0))}"
        return f"Positioned({edges[0]}, {edges[1]}, child: {inner})"

    def _box(self, args: list[str], children: list[str], depth: int) -> str:
        pad = " " * depth
        parts = list(args)
        if children:
            kids = "".join(f"\n{pad}    {c}," for c in children)
            parts.append(f"children: [{kids}\n{pad}  ]")
        body = "".join(f"\n{pad}  {p}," for p in parts)
        return f"PenBox({body}\n{pad})"

    def text(self, node: dict, parent_axis: str | None, depth: int) -> str:
        pad = " " * depth
        args = [
            f"size: {num(node['fontSize'])}",
            f"color: const {color(node.get('fill', '#161616'))}",
        ]
        if str(node.get("fontWeight", "normal")) != "normal":
            args.append(f"weight: {weight(node['fontWeight'])}")
        if node.get("textAlign") in ALIGN:
            args.append(f"align: {ALIGN[node['textAlign']]}")
        if node.get("lineHeight"):
            args.append(f"lineHeight: {num(node['lineHeight'])}")
        if node.get("letterSpacing"):
            args.append(f"letterSpacing: {num(node['letterSpacing'])}")
        # Only `fixed-width` text reflows in the design file; everything else
        # hugs its content and stays on one line.
        if node.get("textGrowth") != "fixed-width" and "\n" not in node.get(
            "content", ""
        ):
            args.append("softWrap: false")
        body = "".join(f"\n{pad}  {a}," for a in args)
        src = f"PenText({dart_str(node.get('content', ''))},{body}\n{pad})"
        if isinstance(node.get("width"), (int, float)):
            src = f"SizedBox(width: {num(node['width'])}, child: {src})"
        return src

    def icon(self, node: dict, depth: int) -> str:
        name = camel(node["icon"])
        self.icons.add(name)
        size = num(node.get("width", 16))
        return (
            f"Icon(LucideIcons.{name}, size: {size}, "
            f"color: const {color(node.get('fill', '#161616'))})"
        )

    def path(self, node: dict, depth: int) -> str:
        pad = " " * depth
        vb = ", ".join(num(v) for v in node["viewBox"])
        fill = node.get("fill")
        if fill == "none":
            fill = None
        args = [
            f"viewBox: const [{vb}]",
            f"width: {num(node.get('width', 16))}",
            f"height: {num(node.get('height', 16))}",
            f"color: const {color(fill or node.get('stroke') or '#161616')}",
        ]
        if fill is None and node.get("stroke"):
            args.append(f"strokeWidth: {num(node.get('strokeWidth', 1))}")
        if node.get("strokeLinecap") == "round":
            args.append("roundCap: true")
        body = "".join(f"\n{pad}  {a}," for a in args)
        src = f"PenPath({dart_str(node['geometry'])},{body}\n{pad})"
        if node.get("rotation"):
            src = (
                f"Transform.rotate(angle: {num(node['rotation'])} * 3.1415926535 "
                f"/ 180, child: {src})"
            )
        return src

    def ellipse(self, node: dict, depth: int) -> str:
        args = [
            f"width: {num(node.get('width', 0))}",
            f"height: {num(node.get('height', node.get('width', 0)))}",
            f"color: const {color(node.get('fill', '#161616'))}",
        ]
        for key, dart in (("innerRadius", "ring"), ("startAngle", "start"),
                          ("sweepAngle", "sweep"), ("rotation", "rotation")):
            if node.get(key) is not None:
                args.append(f"{dart}: {num(node[key])}")
        return "PenEllipse(" + ", ".join(args) + ")"

    def node(self, node: dict, parent_axis: str | None, depth: int) -> str:
        kind = node.get("type")
        if kind == "frame":
            src = self.frame(node, parent_axis, depth)
        elif kind == "text":
            src = self.text(node, parent_axis, depth)
        elif kind == "icon":
            src = self.icon(node, depth)
        elif kind == "path":
            src = self.path(node, depth)
        elif kind == "ellipse":
            src = self.ellipse(node, depth)
        elif kind == "rectangle":
            src = self.frame({**node, "children": [], "layout": "none"},
                             parent_axis, depth)
        else:
            src = f"const SizedBox.shrink() /* unsupported: {kind} */"
        if self._expands(node, parent_axis):
            src = f"Expanded(child: {src})"
        return src


# -------------------------------------------------------------------- driver

HEADER = """// GENERATED by tool/pen2dart.py from
// specs/projects/evidencecam/design-spec/pencil-app-dna.pen — do not edit by
// hand; re-run the generator when the design file changes.
//
// ignore_for_file: lines_longer_than_80_chars, prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables, unused_import
// ignore_for_file: public_member_api_docs, avoid_redundant_argument_values

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
"""


def class_name(screen: str) -> str:
    code = screen.split(" ")[0]
    return "Pen" + re.sub(r"[^A-Za-z0-9]", "", code)


def main() -> None:
    pen_path, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)
    doc = json.loads(pen_path.read_text())
    emitter = Emitter()

    for flow in doc["children"]:
        screens = [c for c in flow.get("children", []) if c.get("type") == "frame"]
        if not screens:
            continue
        slug = re.sub(r"[^a-z0-9]+", "_", flow["name"].lower()).strip("_")
        slug = re.sub(r"^flow_(\d)_.*", r"flow\1", slug) or slug
        body = [HEADER]
        for screen in sorted(screens, key=lambda s: s["name"]):
            name = class_name(screen["name"])
            tree = emitter.frame({**screen, "x": 0, "y": 0}, None, 4, root=True)
            body.append(
                f"/// {screen['name']} — {flow['name']}.\n"
                f"class {name} extends StatelessWidget {{\n"
                f"  const {name}({{super.key}});\n\n"
                f"  @override\n"
                f"  Widget build(BuildContext context) {{\n"
                f"    return {tree};\n"
                f"  }}\n"
                f"}}\n"
            )
        path = out_dir / f"{slug}.dart"
        path.write_text("\n".join(body))
        print(f"wrote {path} ({len(screens)} screens)")

    print("icons:", " ".join(sorted(emitter.icons)))
    print("images:", " ".join(sorted(emitter.images)))


if __name__ == "__main__":
    main()
