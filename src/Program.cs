using System;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.Extensions.DependencyInjection;

namespace HelloHttp {
    public class Program {

        public static void Main(string[] args) => CreateWebHostBuilder(args).Build().Run();

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .ConfigureServices(services => {
                    services.AddResponseCompression(opt => {
                        opt.Providers.Add<GzipCompressionProvider>();
                        opt.Providers.Add<BrotliCompressionProvider>();

                        opt.EnableForHttps = true;
                        opt.MimeTypes = new[] {
					        // Default
					        "text/plain",
                            "text/css",
                            "application/javascript",
                            "text/html",
                            "application/xml",
                            "text/xml",
                            "application/json",
                            "text/json",

					        // Custom
					        "application/atom+xml",
                            "application/xaml+xml",
                            "application/svg+xml",
                            "image/svg+xml",
                            "application/vnd.ms-fontobject",
                            "font/otf"
                        };
                    });
                })
                .Configure(app => {
                    var txt = Environment.GetEnvironmentVariable("HelloHttp:Output") ?? "Hello world!";
                    app.UseResponseCompression();
                    app.Run(async (context) => {
                        await context.Response.WriteAsync(txt);
                    });
                });

    }
}
