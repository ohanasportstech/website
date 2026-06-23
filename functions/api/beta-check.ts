interface Env {
  BETA_SECRET: string;
}

export const onRequest = async (context: { request: Request; env: Env }) => {
  const url = new URL(context.request.url);
  const secret = url.searchParams.get('secret');

  if (secret && secret === context.env.BETA_SECRET) {
    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-store',
      },
    });
  }

  return new Response(JSON.stringify({ ok: false }), {
    status: 403,
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store',
    },
  });
};
