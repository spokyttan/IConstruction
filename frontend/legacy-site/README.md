# IConstruction Frontend (Opción A: Server-rendered + JS ES5)

Objetivo: soportar IE10, Chrome >= 40 y Firefox >= 32 con HTML renderizado en servidor, JS mínimo en ES5 y polyfills.

## Páginas
- login.html: Form de login; guarda el token en sessionStorage/localStorage.
- stock.html: Consulta stock (herramientas/materiales) por bodega.
- prestamos.html: Crear préstamo.
- devolucion.html: Registrar devolución.

## Polyfills recomendados
- core-js (Promise, Object.assign, Array.*)
- whatwg-fetch (o fallback a XHR si fetch no disponible)
- classList, CustomEvent, Element.closest
- raf (requestAnimationFrame)

En este ejemplo usamos XHR para máxima compatibilidad (evitamos fetch).

## Configuración
- Servidas como archivos estáticos (wwwroot) desde la API .NET o desde cualquier hosting estático.
- Ajusta `BASE_URL` en `js/config.js`.
