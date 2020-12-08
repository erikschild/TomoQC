#' @title Tomosequencing quality control function
#'
#' @import patchwork ggplot2
#' @importFrom stats na.omit
#' @importFrom tibble tibble
#' @importFrom tibble column_to_rownames
#' @importFrom tidyr pivot_longer
#' @importFrom scales log2_trans
#' @param transcripts data.frame containing transcript counts, with gene names in the first column
#' @param reads data.frame containing read counts, with gene names in the first column
#' @param umis data.frame containing UMI counts, with genen names in the first column
#' @param plot_title a string to title the QC plot
#' @param cutoff_spike a cutoff value for spike-in percentage of total Transcripts (ranges from 0 to 100)
#' @param cutoff_genes a cutoff value for minimum unique gene count per slice
#' @param spike_ins Controls whether spike-ins were used, and thus if a spike-ins percentage plot should be generated. Default = TRUE
#' @return Provides various QC plots to quickly assess the quality of tomo-seq data
#' @export


tomo_quality <- function(transcripts, reads, umis, plot_title = "QC plots", cutoff_spike = 25, cutoff_genes = 2000, spike_ins = T){

  QC_theme <-   theme(axis.line = element_line(colour="Gray10", size = 1),
                      axis.text = element_text(colour = "black"),
                      panel.grid = element_blank(),
                      plot.background = element_rect(fill = "white"),
                      panel.background = element_rect(fill = "white"),
                      legend.background = element_rect(fill = "white"),
                      legend.key = element_rect(fill = "white", colour = "white"),
                      strip.background = element_rect(fill = "gray80"),
                      strip.text = element_text(colour = "black"),
                      text = element_text(colour = "black", family = "sans"))


  os <- (tibble::column_to_rownames(reads, colnames(reads[1]))/tibble::column_to_rownames(umis, colnames(umis[1])))
  os <- tidyr::pivot_longer(os,cols = 1:96)
  os <- na.omit(os)
  overseq_plot <- ggplot2::ggplot(os, aes(x = .data$value))+
    geom_histogram(binwidth = 0.1, fill = "deepskyblue") +
    labs(title = "Oversequencing",x = "Reads per UMI", y = "Occurrence") +
    scale_x_continuous(trans = scales::log2_trans(), limits = c(0.9,16), breaks = c(1,2,4,8,16))+
    QC_theme

  spike_in_counts <- dplyr::filter(transcripts, grepl("ERCC",transcripts$GENEID))

  inform <- tibble::tibble("Slice" = rank(1:96),
                           Genes =  colSums(dplyr::filter(transcripts, !grepl("ERCC",transcripts$GENEID))[,-1]>0),
                           Spike_ins_percentage = (colSums(spike_in_counts[,-1])/colSums(transcripts[,-1])*100),
                           Wormslice = "Worm")
  inform$Wormslice[which(inform$Spike_ins_percentage >cutoff_spike | inform$Genes < cutoff_genes)] <- "not_worm"

  if(spike_ins){
    p <-   ggplot2::ggplot(inform, aes(x = .data$Slice, y = .data$Spike_ins_percentage, fill = .data$Wormslice))+
      geom_col(width = 0.8)+
      geom_hline(aes(yintercept=cutoff_spike), col = "Gray10", size = 1)+
      ggtitle("Spike-ins per slice")+
      scale_fill_manual(values = c("Worm" = "deepskyblue",  "not_worm" = "magenta"))+
      scale_x_continuous(breaks = seq(1,96, by = 5))+
      scale_y_continuous(name = "Percentage", breaks = c(0, 25, 50, 75, 100), labels = c("0%", "25%", "50%", "75%", "100%"), expand = c(0,0))+
      xlab("Slices")+
      QC_theme+
      theme(legend.position = "none", axis.text.x = element_text(size = 8))
  }

  q <- ggplot2::ggplot(inform, aes(x = .data$Slice, y = .data$Genes, fill = .data$Wormslice)) +
    geom_col(width = 0.8)+
    geom_hline(aes(yintercept=cutoff_genes), col = "Gray10", size = 1)+
    scale_fill_manual(values = c("Worm" = "deepskyblue", "not_worm" = "magenta"))+
    scale_y_log10() +
    scale_x_continuous(breaks = seq(1,96, by = 5))+
    xlab("Slices")+
    ylab("Genes")+
    QC_theme+
    theme(legend.position = "none", axis.text.x = element_text(size = 8)) +
    labs(title = "Unique genes per slice")+
    coord_cartesian(ylim = c(10,20000))

  if(spike_ins){
    suppressWarnings(
      print(overseq_plot + (p + q + plot_layout(ncol = 1)) +  plot_layout(ncol = 2, widths = c(1,3))+ plot_annotation(title = plot_title))
    )
  }else{
    suppressWarnings(
      print(overseq_plot + (q + plot_layout(ncol = 1)) +  plot_layout(ncol = 2, widths = c(1,3))+ plot_annotation(title = plot_title))
    )
  }

  return(inform)
}
