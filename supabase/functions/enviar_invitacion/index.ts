// 1. Importamos la herramienta estándar para crear servidores web
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    // 2. Capturamos el paquete (JSON) que nos enviará el Webhook automáticamente
    const payload = await req.json();
    
    // 3. Extraemos la fila que se acaba de insertar en la tabla board_invites
    const invitacion = payload.record;
    
    // Guardamos las variables clave
    const emailDestino = invitacion.email;
    const tokenSecreto = invitacion.id;

// Hacemos la llamada HTTP a los servidores de Resend
    const respuestaResend = await fetch("https://api.resend.com/emails", {
      method: "POST",
      
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${Deno.env.get("RESEND_KEY")}`
      },
      
      body: JSON.stringify({
        from: "onboarding@resend.dev", // Correo de pruebas obligatorio de Resend
        to: emailDestino,
        subject: "¡Te han invitado a colaborar en un tablero!",
        html: `
          <div style="font-family: Arial, sans-serif; padding: 20px;">
            <h2>¡Tienes una nueva invitación!</h2>
            <p>Alguien quiere compartir un tablero contigo en la aplicación.</p>
            <p>Haz clic en el siguiente botón desde tu móvil para unirte:</p>
            
            <a href="kantask://invite?token=${tokenSecreto}" 
               style="display: inline-block; padding: 10px 20px; background-color: #000; color: #fff; text-decoration: none; border-radius: 5px;">
               Aceptar Invitación
            </a>
          </div>
        `
      })
    });

    // Leemos lo que nos contesta Resend para saber si hubo error o éxito
    const datosResend = await respuestaResend.json();
    console.log("Respuesta del servidor de correos:", datosResend);
    // Si todo va bien, le decimos a Supabase que la función terminó correctamente
    return new Response(
      JSON.stringify({ mensaje: "Correo enviado con éxito a " + emailDestino }),
      { headers: { "Content-Type": "application/json" }, status: 200 },
    )
  } catch (error) {
    // Si algo explota, devolvemos el error
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { "Content-Type": "application/json" }, status: 400 },
    )
  }
})
