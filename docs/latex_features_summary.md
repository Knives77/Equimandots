# Características de LaTeX agregadas (Estilo Gilles Castel)

Aquí tienes el resumen completo de todo lo que implementamos en esta configuración de AstroNvim para que funcione como el entorno de matemáticas avanzado de Castel.

## 1. Organización y Compilación (VimTeX)
- **Directorio de compilación (`build/`)**: Al compilar, todos los archivos generados (`.pdf`, `.aux`, `.log`, `.synctex.gz`, etc.) se guardan automáticamente en una subcarpeta `build/`. Esto mantiene tu carpeta de proyecto siempre limpia.
- **Compilación continua**: Usando `,ll` inicias `latexmk` en modo continuo, que recompilará tu documento en el fondo automáticamente cada vez que guardes el archivo.
- **Forward & Inverse Search (Zathura)**: Soporte completo para hacer clic en el PDF (Zathura) y que el cursor salte a esa línea de código en Neovim, o viceversa (`,lv`).
- **Modo silencioso y optimizado**: El compilador no se frena si encuentra errores, lo que hace la iteración mucho más rápida.
- **Ocultamiento de código (Conceal)**: VimTeX oculta barras invertidas, convierte símbolos como `\alpha` a `α`, y colapsa los `$` para que el código crudo sea mucho más fácil de leer.

## 2. Corrección Ortográfica Inteligente (Spell Check)
- **Idiomas dinámicos por carpeta**: El diccionario activo cambia automáticamente dependiendo de la ruta donde esté guardado tu documento `.tex`:
  - Si la ruta incluye `/en/` o `/english/` → se usa inglés (`en_us`).
  - Si la ruta incluye `/es/`, `/español/` o `/espanol/` → se usa español (`es`).
  - En cualquier otra ruta → se usan ambos idiomas simultáneamente.
- **Corrección "al vuelo" (`Ctrl+L`)**: En modo Insertar, al presionar `Ctrl+L`, Neovim saltará al último error ortográfico escrito, lo corregirá con la primera sugerencia, y te devolverá exactamente a donde estabas escribiendo, todo en un milisegundo sin perder el flujo.

## 3. Snippets Avanzados (LuaSnip) - ~130 comandos
Configuramos una suite masiva de "autosnippets" que se expanden solos, sin necesidad de presionar Tab. Son conscientes del contexto, es decir, solo funcionan en modo matemático o en modo texto según corresponda.

### Contexto de Modo Matemático
*Estos snippets solo funcionan entre `$...$` o `\[...\]`.*

- **Subíndices Automáticos**: Letras seguidas de dígitos se convierten en subíndices de inmediato:
  - `a1` → `a_1`
  - `x_12` → `x_{12}`
- **Fracciones con Regex**: Sistema inteligente para generar fracciones escribiendo `/`:
  - `//` → `\frac{}{}`
  - `3/` → `\frac{3}{}`
  - `4\pi^2/` → `\frac{4\pi^2}{}`
- **Operadores Postfix**: Escribe el acento o vector *después* del símbolo, como en la vida real:
  - `phat` → `\hat{p}`
  - `zbar` → `\overline{z}`
  - `xdot` → `\dot{x}`
  - `v,.` → `\vec{v}`
- **Letras Griegas (Prefix `;`)**: Unas ~40 letras griegas accesibles al instante:
  - `;a` → `\alpha`, `;b` → `\beta`, `;G` → `\Gamma`, etc.
- **Superíndices Rápidos**:
  - `sr` → `^2`
  - `cb` → `^3`
  - `invs` → `^{-1}`
  - `td` → `^{...}`
- **Símbolos y Relaciones**: 
  - `->` → `\to`, `=>` → `\implies`, `!=` → `\neq`
  - `cc` → `\subset`, `inn` → `\in`, `ooo` → `\infty`
- **Funciones y Delimitadores**:
  - `lr(` → `\left( \right)`
  - `lim` → `\lim_{n \to \infty}`
  - `dint` → `\int_{a}^{b} \dots dx`
- **Matrices**: `pmat` para `pmatrix`, `bmat`, `vmat`.

### Contexto General y Texto
- **Modos Matemáticos**:
  - `mk` → `$...$` (con detección inteligente de espacios)
  - `dm` → `\[ ... \]` (con el punto final automático)
- **Entornos Automáticos**: Escribe `beg` al inicio de una línea para generar `\begin{} ... \end{}`. O atajos como `ali` para `align*`.
- **Estructura y Formato**: Atajos para negritas (`bf`), cursivas (`it`), secciones (`sec`, `ssec`), `\label` (`lab`), y `\ref` (`ref`).
- **Plantilla (`template`)**: Genera un documento base completo al instante.

## 4. Evaluador de Sympy 
Si tienes Python y la librería `sympy` instalada, puedes usar el snippet matemático interactivo:
- Selecciona el bloque escribiendo `sym` y presionando `Tab`.
- Escribe tu expresión y da `Tab` para salir.
- Presiona `Tab` nuevamente y Neovim lo reemplazará usando el motor simbólico (ej. devolviendo `2`, o desarrollando polinomios y derivadas reales y poniéndolas en formato LaTeX).

## 5. Previsualización de Ecuaciones (nabla.nvim)
- **ASCII Art UI**: Si no tienes un lector PDF a la mano o quieres comprobar rápido si tipeaste bien la ecuación, coloca el cursor encima de ella y presiona `,lp`. Mostrará la renderización visual en formato ASCII directamente flotando en tu editor.

## 6. Autocompletado LSP Moderno (TexLab)
- **`texlab` instalado vía Mason**: Tienes el LSP oficial trabajando en segundo plano sin entrar en conflicto con la compilación de VimTeX.
- Te provee autocompletado nativo para paquetes, comandos, y lo más importante: las referencias (ve tus `\label` sugeridos cuando escribes `\ref`).
- Te avisa de malas prácticas o errores de sintaxis gracias al linter `chktex`.
